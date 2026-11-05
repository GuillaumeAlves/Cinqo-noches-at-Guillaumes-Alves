# Police VHS — à déposer ici

Le menu utilise une police style VHS / OSD (affichage de magnétoscope).
Dépose le fichier de police dans ce dossier, par exemple :

- `fonts/VCR_OSD_MONO.ttf` (VCR OSD Mono, de Riciery Leal — gratuite, usage perso et commercial)

Puis, dans Godot (éditeur web ou desktop) :

1. Clique sur le fichier `.ttf` dans le panneau Fichiers → il devient une ressource `FontFile`.
2. Ouvre `scenes/main_menu.tscn` et assigne la police :
   - nœud `Title` : propriété **Theme Overrides → Fonts → Font** = la police, taille 64.
   - nœuds `NewGameButton`, `ContinueButton`, `SettingsButton` : même chose, taille 32.
   - (Astuce : crée un `Theme` partagé `themes/main_theme.tres` avec cette police en police par défaut, pour ne pas la réassigner à chaque nouveau nœud de texte.)
3. Vérifie que le texte s'affiche bien (la police VCR OSD Mono est une police bitmap/pixel : elle rend mieux à des tailles multiples de sa taille de base, ~21 px — 64 et 32 restent lisibles).

Alternative libre et sans ambiguïté de licence : **VT323** (Google Fonts, licence OFL) — téléchargeable depuis https://github.com/google/fonts/tree/main/ofl/vt323 (`VT323-Regular.ttf`). Même procédure.

> Note : je ne peux pas déposer le fichier binaire de la police moi-même dans cette repo (pas d'accès à ton compte GitHub). Le code du menu est déjà prêt à recevoir la police : il suffit de la déposer ici et de l'assigner comme ci-dessus.
