# Police VHS — VT323 (intégrée)

Le menu utilise la police **VT323** (Google Fonts, licence OFL — libre, y compris pour un dépôt public).

- Fichier : `fonts/VT323-Regular.ttf`
- Intégrée via un `Theme` partagé : `themes/main_theme.tres` (police par défaut, taille 32, couleurs gris clair / blanc au survol), assigné à la racine de `scenes/main_menu.tscn`.
- Le titre garde sa taille 64 via un `theme_override_font_sizes/font_size` local.

## Modifier la police ou la taille

- Pour changer la police de tout le menu : ouvrir `themes/main_theme.tres` et changer `default_font` (ou `default_font_size`).
- Pour une taille ponctuelle : ajouter `theme_override_font_sizes/font_size` sur le nœud concerné.

## Alternatives

- **VCR OSD Mono** (Riciery Leal) : look magnétoscope OSD, mais licence plus floue pour un dépôt public — à vérifier avant usage.
- **VT323** : déjà en place, OFL, sans ambiguïté.

> Le fichier `.ttf` est versionné dans ce dossier ; Godot génère `VT323-Regular.ttf.import` à l'import (ne pas éditer à la main).
