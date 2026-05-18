<div align="center">

# 🔮 Grimoire

### Un grimoire Hyprland pour la communauté francophone

![Version](https://img.shields.io/badge/version-1.0.0-e0789a?style=for-the-badge)
![Hyprland](https://img.shields.io/badge/Hyprland-0.55-bd93f9?style=for-the-badge)
![Lua](https://img.shields.io/badge/config-Lua-ffb86c?style=for-the-badge)
![Licence](https://img.shields.io/badge/licence-MIT-69ff94?style=for-the-badge)
![Langue](https://img.shields.io/badge/langue-Français-e0789a?style=for-the-badge)

</div>

---

## 🔮 À propos

**Grimoire** est une configuration Hyprland complète, écrite entièrement en **Lua**, documentée en français et pensée pour la communauté francophone Linux.

Inspiré par [ML4W](https://github.com/mylinuxforwork/dotfiles), [End4](https://github.com/end-4/dots-hyprland), [Omarchy](https://github.com/basecamp/omarchy) et [TypeCraft](https://www.youtube.com/@typecraft_dev), Grimoire propose une expérience cohérente et moderne avec le thème **Dracula Warm** — une variation chaude et unique du célèbre thème Dracula.

## ✨ Stack

| Composant | Outil |
|---|---|
| Compositeur | Hyprland 0.55 (Lua) |
| Barre | Waybar |
| Terminal | Kitty |
| Shell | Fish + Starship |
| Launcher | Rofi |
| Notifications | SwayNC |
| Éditeur | Neovim + LazyVim |
| Wallpaper | Hyprpaper |
| Fetch | Fastfetch |
| Distro | CachyOS / Arch Linux |

## 🚀 Installation

### Prérequis

- Arch Linux ou CachyOS
- Connexion internet
- Droits sudo

### Installation automatique

```bash
git clone git@github.com:jonathanbourriauddev/grimoire.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

### Installation manuelle

```bash
git clone git@github.com:jonathanbourriauddev/grimoire.git ~/dotfiles
cd ~/dotfiles
stow hypr waybar kitty rofi fish starship swaync fastfetch hyprpaper nvim
chsh -s /usr/bin/fish
```

## ⌨️ Raccourcis

| Raccourci | Action |
|---|---|
| `SUPER + Entrée` | Terminal (Kitty) |
| `SUPER + R` | Launcher (Rofi) |
| `SUPER + C` | Fermer la fenêtre |
| `SUPER + W` | Sélecteur de wallpaper |
| `SUPER + F` | Plein écran |
| `SUPER + V` | Fenêtre flottante |
| `SUPER + B` | Navigateur |
| `SUPER + SHIFT + Q` | Menu de déconnexion |
| `SUPER + 1-5` | Changer de workspace |
| `Print` | Capture région → presse-papier |
| `SHIFT + Print` | Capture région → fichier |

## 🎨 Thème — Dracula Warm

| Couleur | Hex | Usage |
|---|---|---|
| Background | `#221a1a` | Fond principal |
| Surface | `#2d2020` | Surfaces |
| Primary | `#e0789a` | Accent rose-violet |
| Secondary | `#ffb86c` | Orange |
| Text | `#f8f8f2` | Texte |
| Cyan | `#a4ffff` | Info |
| Green | `#69ff94` | Succès |

## 📁 Structure

dotfiles/
├── hypr/          # Hyprland (Lua) — config modulaire
│   └── .config/hypr/
│       ├── hyprland.lua   # point d'entrée
│       └── lua/           # modules
│           ├── colors.lua
│           ├── keybinds.lua
│           ├── look.lua
│           ├── input.lua
│           ├── monitors.lua
│           ├── autostart.lua
│           ├── rules.lua
│           └── env.lua
├── waybar/        # Barre de statut
├── kitty/         # Terminal
├── rofi/          # Launcher
├── fish/          # Shell
├── starship/      # Prompt
├── swaync/        # Notifications
├── fastfetch/     # Fetch
├── nvim/          # Neovim + LazyVim
├── hyprpaper/     # Wallpaper
├── themes/        # Palettes de couleurs
├── scripts/       # Scripts utilitaires
├── docs/          # Documentation
└── install.sh     # Installateur

## 🗺️ Roadmap

- [x] V1 — Fondations (config Lua modulaire, Dracula Warm, install.sh)
- [ ] V1.1 — Polish (keybinds, gaps, wallpapers, wlogout, hypridle)
- [ ] V2 — Modernisation (AGS/Astal, Ghostty, thèmes multiples, swww)
- [ ] V3 — Communauté (site vitrine, Discord francophone)

## 👤 Auteur

**Jonathan Bourriaud** — [@jonathanbourriauddev](https://github.com/jonathanbourriauddev)

Technicien réseau & développeur fullstack — side project passion.

## 📄 Licence

MIT — libre d'utilisation, de modification et de distribution.
