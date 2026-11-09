# Panneau admin (outil de test)

Pendant une nuit, appuyer sur **P** pour ouvrir / fermer le panneau.

- **Partie :** pause, figer l'IA, heure suivante, gagner la nuit, énergie 100 % / 5 %, panne de courant, brouillage caméra.
- **Positions :** choisir la pièce de Super Clovis, White Paul-Henri, Guillaume Alves (y compris devant la porte ou dans le bureau) et l'étape de Joey Joestar.
- **Joey :** le faire sortir de sa cove, le faire arriver tout de suite à la porte.
- **Jumpscare instantané :** par n'importe quel personnage, Adam compris (ferme le jeu).
- **Secrets :** faire apparaître Adam, ou le rendre garanti (1/1) en baissant la tablette depuis la cam 1A.

Le panneau bloque le scroll du bureau et les caméras tant qu'il est ouvert.

## Supprimer le panneau

**Supprimer ce dossier `admin/`.** C'est tout : le jeu ne le charge que s'il existe
(`_load_admin_panel()` dans `scripts/game/office.gd`), rien d'autre à modifier.

Fichiers : `admin_panel.gd` (code), `admin_theme.tres` (style vert « terminal »), `admin_icon.svg` (icône).
