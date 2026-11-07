extends Node
## Autoload « Sfx » — effets sonores.
##
## Même principe que les images (RenderSlot) :
##   1. Le jeu cherche res://assets/sounds/<nom>.ogg (ou .wav / .mp3).
##   2. S'il existe, il est joué.
##   3. Sinon, un son TEMPORAIRE est synthétisé par le jeu (bruits simples, voir _synth_*).
## => Pour remplacer un son : déposer le fichier au bon nom (liste : assets/sounds/README.md).
##
## Utilisation : Sfx.play("door_close") · Sfx.play_loop("light_buzz") · Sfx.stop("light_buzz")

const SOUNDS_DIR := "res://assets/sounds/"
const EXTENSIONS := [".ogg", ".wav", ".mp3"]
const MIX_RATE := 22050
const POOL_SIZE := 12

## Volume de chaque son (dB). À ajuster une fois les vrais sons en place.
const VOLUME_DB := {
	"cam_open": -6.0,
	"cam_close": -6.0,
	"cam_switch": -8.0,
	"cam_glitch": -10.0,
	"cam_static": -24.0,
	"door_close": -2.0,
	"door_open": -4.0,
	"door_bang": 0.0,
	"door_error": -8.0,
	"light_buzz": -16.0,
	"jumpscare": 0.0,
}
## Sons joués en boucle (le fichier fourni doit idéalement boucler proprement).
const LOOPING := ["cam_static", "light_buzz"]

var _streams: Dictionary = {}
var _pool: Array[AudioStreamPlayer] = []
var _loops: Dictionary = {}  # nom -> AudioStreamPlayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_pool.append(p)


## Joue un son une fois.
func play(sound: String, pitch: float = 1.0) -> void:
	var stream := get_stream(sound)
	if stream == null:
		return
	var p := _free_player()
	p.stream = stream
	p.volume_db = VOLUME_DB.get(sound, 0.0)
	p.pitch_scale = pitch
	p.play()


## Démarre un son en boucle (sans effet s'il tourne déjà).
func play_loop(sound: String) -> void:
	if _loops.has(sound):
		return
	var stream := get_stream(sound)
	if stream == null:
		return
	var p := AudioStreamPlayer.new()
	p.stream = stream
	p.volume_db = VOLUME_DB.get(sound, 0.0)
	add_child(p)
	p.play()
	_loops[sound] = p


func stop(sound: String) -> void:
	if _loops.has(sound):
		(_loops[sound] as AudioStreamPlayer).queue_free()
		_loops.erase(sound)


## Coupe tout (changement de scène, jumpscare...).
func stop_all() -> void:
	for s: String in _loops.keys():
		stop(s)
	for p: AudioStreamPlayer in _pool:
		p.stop()


## Vrai si un fichier son a été déposé pour ce nom.
func has_file(sound: String) -> bool:
	for ext: String in EXTENSIONS:
		if ResourceLoader.exists(SOUNDS_DIR + sound + ext):
			return true
	return false


## Prépare tous les sons d'avance (évite un petit gel au premier jumpscare).
func warm_up() -> void:
	for sound: String in VOLUME_DB:
		get_stream(sound)


func get_stream(sound: String) -> AudioStream:
	if _streams.has(sound):
		return _streams[sound]
	var stream: AudioStream = null
	for ext: String in EXTENSIONS:
		var path: String = SOUNDS_DIR + sound + ext
		if ResourceLoader.exists(path):
			stream = load(path) as AudioStream
			if stream != null:
				break
	if stream != null:
		_set_loop(stream, sound in LOOPING)
	else:
		stream = _synthesize(sound)
	_streams[sound] = stream
	return stream


func _free_player() -> AudioStreamPlayer:
	for p: AudioStreamPlayer in _pool:
		if not p.playing:
			return p
	return _pool[0]


func _set_loop(stream: AudioStream, loop: bool) -> void:
	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = loop
	elif stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = loop
	elif stream is AudioStreamWAV and loop:
		var w := stream as AudioStreamWAV
		w.loop_mode = AudioStreamWAV.LOOP_FORWARD
		w.loop_begin = 0
		w.loop_end = int(w.get_length() * w.mix_rate)


# =============================================================================
# Sons temporaires synthétisés (remplacés dès qu'un fichier est fourni)
# =============================================================================

func _synthesize(sound: String) -> AudioStream:
	var samples: PackedFloat32Array
	match sound:
		"cam_open": samples = _synth_whoosh(0.28, true)
		"cam_close": samples = _synth_whoosh(0.24, false)
		"cam_switch": samples = _synth_blip()
		"cam_glitch": samples = _synth_noise(0.5, 0.9, 0.0)
		"cam_static": samples = _synth_noise(2.0, 0.5, 0.6)
		"door_close": samples = _synth_slam(0.55, 70.0)
		"door_open": samples = _synth_slam(0.4, 110.0)
		"door_bang": samples = _synth_bangs()
		"door_error": samples = _synth_tone(0.25, 140.0, 0.5, true)
		"light_buzz": samples = _synth_buzz(1.0)
		"jumpscare": samples = _synth_scream(1.3)
		_:
			push_warning("Son inconnu : " + sound)
			return null
	return _to_wav(samples, sound in LOOPING)


func _to_wav(samples: PackedFloat32Array, loop: bool) -> AudioStreamWAV:
	var data := PackedByteArray()
	data.resize(samples.size() * 2)
	for i in samples.size():
		data.encode_s16(i * 2, int(clampf(samples[i], -1.0, 1.0) * 32767.0))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = MIX_RATE
	w.stereo = false
	w.data = data
	if loop:
		w.loop_mode = AudioStreamWAV.LOOP_FORWARD
		w.loop_begin = 0
		w.loop_end = samples.size()
	return w


func _buf(seconds: float) -> PackedFloat32Array:
	var b := PackedFloat32Array()
	b.resize(int(seconds * MIX_RATE))
	return b


## Souffle de tablette qui monte (rising) ou descend + petit clic.
func _synth_whoosh(dur: float, rising: bool) -> PackedFloat32Array:
	var b := _buf(dur)
	var lp := 0.0
	for i in b.size():
		var t := float(i) / b.size()
		var cutoff := lerpf(0.05, 0.4, t if rising else 1.0 - t)
		lp += (randf_range(-1, 1) - lp) * cutoff
		var env := sin(PI * t)
		b[i] = lp * env * 0.9
	# clic plastique à la fin
	var click_at := int(b.size() * 0.85)
	for i in range(click_at, mini(click_at + 200, b.size())):
		b[i] += sin(float(i - click_at) * 0.9) * 0.5 * (1.0 - float(i - click_at) / 200.0)
	return b


## Bip court de changement de caméra.
func _synth_blip() -> PackedFloat32Array:
	var b := _buf(0.09)
	for i in b.size():
		var t := float(i) / MIX_RATE
		var env := 1.0 - float(i) / b.size()
		var sq := 1.0 if fmod(t * 1400.0, 1.0) < 0.5 else -1.0
		b[i] = (sq * 0.25 + randf_range(-1, 1) * 0.25) * env
	return b


## Neige / grésillement. tail = proportion du son sans fondu (boucle).
func _synth_noise(dur: float, amp: float, smooth: float) -> PackedFloat32Array:
	var b := _buf(dur)
	var lp := 0.0
	for i in b.size():
		var t := float(i) / b.size()
		lp += (randf_range(-1, 1) - lp) * (1.0 - smooth * 0.8)
		var env := 1.0 if smooth > 0.0 else (1.0 - t) * (1.0 - t)
		# crépitements aléatoires
		var crackle := randf_range(-1, 1) if randf() < 0.02 else 0.0
		b[i] = (lp + crackle * 0.6) * amp * env
	return b


## Porte métallique qui claque : grave + bruit métallique.
func _synth_slam(dur: float, freq: float) -> PackedFloat32Array:
	var b := _buf(dur)
	var lp := 0.0
	for i in b.size():
		var t := float(i) / MIX_RATE
		var env := exp(-t * 9.0)
		lp += (randf_range(-1, 1) - lp) * 0.3
		var thud := sin(TAU * freq * t * (1.0 - t * 0.6)) * env
		var metal := (sin(TAU * 523.0 * t) * 0.3 + sin(TAU * 831.0 * t) * 0.2) * exp(-t * 14.0)
		var hit := lp * exp(-t * 40.0)
		b[i] = (thud * 0.9 + metal + hit * 0.8) * 0.55
	return b


## Joey qui tambourine sur la porte fermée.
func _synth_bangs() -> PackedFloat32Array:
	var b := _buf(1.1)
	var one := _synth_slam(0.3, 60.0)
	for k in 4:
		var start := int((0.05 + k * 0.24 + randf() * 0.04) * MIX_RATE)
		for i in one.size():
			if start + i < b.size():
				b[start + i] += one[i] * (1.0 - k * 0.12)
	return b


## Bourdonnement court (bouton qui ne répond plus).
func _synth_tone(dur: float, freq: float, amp: float, square: bool) -> PackedFloat32Array:
	var b := _buf(dur)
	for i in b.size():
		var t := float(i) / MIX_RATE
		var ph := fmod(t * freq, 1.0)
		var v := (1.0 if ph < 0.5 else -1.0) if square else sin(TAU * ph)
		var env := minf(1.0, (1.0 - float(i) / b.size()) * 6.0)
		b[i] = v * amp * env
	return b


## Bourdonnement de néon (lumière du couloir), boucle d'1 s.
func _synth_buzz(dur: float) -> PackedFloat32Array:
	var b := _buf(dur)
	for i in b.size():
		var t := float(i) / MIX_RATE
		# 100 Hz exact → boucle sans clic sur 1 s
		var v := sin(TAU * 100.0 * t) * 0.5 + sin(TAU * 200.0 * t) * 0.25 + sin(TAU * 300.0 * t) * 0.12
		v = clampf(v * 1.6, -0.8, 0.8)
		b[i] = v * 0.6 + randf_range(-1, 1) * 0.05
	return b


## Cri de jumpscare : dents de scie saturées qui montent + bruit.
func _synth_scream(dur: float) -> PackedFloat32Array:
	var b := _buf(dur)
	var phases := [0.0, 0.0, 0.0]
	var detune := [1.0, 1.013, 0.497]
	for i in b.size():
		var t := float(i) / MIX_RATE
		var x := float(i) / b.size()
		var f := lerpf(420.0, 980.0, minf(x * 3.0, 1.0)) * (1.0 + sin(TAU * 7.0 * t) * 0.06)
		var v := 0.0
		for k in 3:
			phases[k] = fmod(phases[k] + f * detune[k] / MIX_RATE, 1.0)
			v += (phases[k] * 2.0 - 1.0) * (0.45 if k < 2 else 0.6)
		v += randf_range(-1, 1) * 0.5
		v = clampf(v * 2.2, -1.0, 1.0)  # saturation
		var env := minf(1.0, t * 60.0) * (1.0 if x < 0.75 else (1.0 - x) * 4.0)
		b[i] = v * env * 0.95
	return b
