# Sons — où déposer les fichiers

Même principe que les images (`assets/renders/`) : le jeu cherche `assets/sounds/<nom>.ogg`
(ou `.wav` / `.mp3`). **Si le fichier existe, il est joué ; sinon un son temporaire est
synthétisé par le jeu.** Aucun code à modifier.

Recommandé : **.ogg** (léger pour le web). Les sons en boucle doivent boucler proprement.
Volumes réglables dans `VOLUME_DB` en haut de `scripts/autoload/sound_manager.gd`.

| Fichier | Quand | Boucle |
|---|---|---|
| `cam_open.ogg` | La tablette des caméras se lève | non |
| `cam_close.ogg` | La tablette se baisse | non |
| `cam_switch.ogg` | Changement de caméra (clic sur 1A, 1B...) — bruit de magnétoscope VHS, hauteur légèrement variée à chaque fois | non |
| `cam_glitch.ogg` | Brouillage quand un esprit bouge dans la caméra regardée | non |
| `cam_static.ogg` | Grésillement de fond tant que les caméras sont ouvertes (et écran de game over) | **oui** |
| `door_close.ogg` | Porte qui se ferme (claque) | non |
| `door_open.ogg` | Porte qui se rouvre (aussi pendant la panne de courant) | non |
| `door_bang.ogg` | Joey Joestar tape sur la porte gauche fermée | non |
| `door_error.ogg` | Bouton porte/lumière qui ne répond plus (esprit dans le bureau) | non |
| `light_buzz.ogg` | Bourdonnement tant qu'une lumière de couloir est allumée | **oui** |
| `office_ambience.ogg` | Néon du bureau qui grésille légèrement, en continu tant qu'on est dans le bureau (coupé sur les caméras, à la panne, au jumpscare) | **oui** |
| `jumpscare.ogg` | Cri du jumpscare (le même pour tous pour l'instant) | non |

Cri propre à un esprit : `jumpscare_clovis.ogg`, `jumpscare_paulhenri.ogg`, `jumpscare_joey.ogg`, `jumpscare_guillaume.ogg`, `jumpscare_adam.ogg` — s'il existe, il remplace `jumpscare.ogg` pour cet esprit.
