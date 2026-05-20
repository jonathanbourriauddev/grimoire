#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║         Grimoire Cursor Theme Builder  v2                   ║
# ║  Pipeline : xcur2png → recolor → xcursorgen → install       ║
# ╚══════════════════════════════════════════════════════════════╝

set -euo pipefail

R='\033[0;31m'; G='\033[0;32m'; Y='\033[1;33m'
M='\033[0;35m'; C='\033[0;36m'; W='\033[1;37m'; N='\033[0m'

log()  { echo -e "${C}[grimoire]${N} $*"; }
ok()   { echo -e "${G}[  ok  ]${N} $*"; }
warn() { echo -e "${Y}[ warn ]${N} $*"; }
err()  { echo -e "${R}[ err  ]${N} $*"; exit 1; }

WORK_DIR="$HOME/.cache/grimoire-cursors-build"
THEME_NAME="phinger-cursors-grimoire"
INSTALL_DIR="$HOME/.local/share/icons/$THEME_NAME"
DOTFILES_DIR="$HOME/dotfiles"
SRC_THEME="$WORK_DIR/themes/phinger-cursors-gruvbox-material"

# ── Palette Gruvbox Material → Grimoire ──────────────────────────
declare -A COLOR_MAP=(
    ["#1d2021"]="#221a1a"   # bg sombre → base Grimoire
    ["#282828"]="#2d2020"   # bg principal → surface Grimoire
    ["#32302f"]="#2d2020"   # bg soft → surface
    ["#d4be98"]="#f8f8f2"   # fg/corps curseur → text Grimoire
    ["#ddc7a1"]="#f8f8f2"   # fg bright → text
    ["#e78a4e"]="#ffb86c"   # orange → secondary Grimoire
    ["#d8a657"]="#e07892"   # yellow → primary (rose-violet)
    ["#ea6962"]="#ff6e6e"   # red → tertiary Grimoire
    ["#89b482"]="#a4ffff"   # aqua → cyan Grimoire
    ["#7daea3"]="#bd93f9"   # blue → purple Grimoire
    ["#a9b665"]="#e07892"   # green → primary Grimoire
)

# ── Dépendances ───────────────────────────────────────────────────
check_deps() {
    log "Vérification des dépendances..."
    local missing=()
    for dep in convert xcur2png xcursorgen; do
        command -v "$dep" &>/dev/null || missing+=("$dep")
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        err "Manquant : ${missing[*]}\n  → sudo pacman -S imagemagick xcur2png xorg-xcursorgen"
    fi
    ok "Dépendances OK"
}

# ── Extraction PNGs depuis un binaire xcursor ─────────────────────
extract_cursor() {
    local cursor_bin="$1"   # binaire xcursor source
    local extract_dir="$2"  # dossier de sortie pour les PNGs

    mkdir -p "$extract_dir"
    cd "$extract_dir"
    xcur2png "$cursor_bin" -d "$extract_dir" &>/dev/null || return 1
    cd - > /dev/null
}

# ── Recoloration d'un PNG ─────────────────────────────────────────
recolor_png() {
    local png="$1"

    # Passe 1 : shift HSL global (désaturer légèrement le jaune-brun, boost violet)
    convert "$png" -modulate 95,115,94 "$png"

    # Passe 2 : substitutions précises couleur par couleur
    for grv_hex in "${!COLOR_MAP[@]}"; do
        local grm_hex="${COLOR_MAP[$grv_hex]}"
        convert "$png" -fuzz 18% -fill "$grm_hex" -opaque "$grv_hex" "$png"
    done
}

# ── Génère le fichier .cursor (config xcursorgen) ─────────────────
# Format : <size> <xhot> <yhot> <filename> [<delay_ms>]
generate_cursor_config() {
    local png_dir="$1"
    local cursor_name="$2"
    local config_file="$3"

    > "$config_file"

    # xcur2png génère des fichiers nommés : <cursorname>_<index>.png
    # avec un fichier <cursorname>.cursor contenant les métadonnées hotspot
    # On récupère les infos depuis le .cursor généré par xcur2png
    local xcur2png_config="$png_dir/${cursor_name}.cursor"

    if [[ -f "$xcur2png_config" ]]; then
        # xcur2png génère déjà un .cursor valide — on l'utilise directement
        # en remplaçant juste les chemins vers les PNGs recolorés
        while IFS= read -r line; do
            # Chaque ligne : size xhot yhot filename [delay]
            local size xhot yhot fname rest
            read -r size xhot yhot fname rest <<< "$line" 2>/dev/null || continue
            [[ -z "$size" ]] && continue
            # Remplacer le chemin par le PNG recoloré local
            local basename_png
            basename_png=$(basename "$fname")
            if [[ -f "$png_dir/$basename_png" ]]; then
                echo "$size $xhot $yhot $png_dir/$basename_png $rest" >> "$config_file"
            fi
        done < "$xcur2png_config"
    else
        # Fallback : générer config depuis les PNGs disponibles
        # Hotspot par défaut au centre (sera approximatif)
        for png in "$png_dir"/${cursor_name}_*.png; do
            [[ -f "$png" ]] || continue
            local size
            size=$(convert "$png" -format "%w" info: 2>/dev/null) || continue
            local hot=$(( size / 2 ))
            echo "$size $hot $hot $png" >> "$config_file"
        done
    fi
}

# ── Traitement d'un curseur ───────────────────────────────────────
process_cursor() {
    local cursor_bin="$1"
    local cursor_name
    cursor_name=$(basename "$cursor_bin")
    local work_subdir="$WORK_DIR/extracted/$cursor_name"
    local output_bin="$WORK_DIR/build/$THEME_NAME/cursors/$cursor_name"

    # Extraction
    extract_cursor "$cursor_bin" "$work_subdir" || {
        warn "Extraction échouée pour $cursor_name — copie directe"
        cp "$cursor_bin" "$output_bin"
        return
    }

    # Recoloration de chaque PNG extrait
    local png_count=0
    while IFS= read -r -d '' png; do
        recolor_png "$png"
        ((png_count++))
    done < <(find "$work_subdir" -name "*.png" -print0)

    if [[ $png_count -eq 0 ]]; then
        warn "$cursor_name : aucun PNG extrait — copie directe"
        cp "$cursor_bin" "$output_bin"
        return
    fi

    # Génération config xcursorgen
    local config="$work_subdir/${cursor_name}.cursor"
    generate_cursor_config "$work_subdir" "$cursor_name" "$config"

    if [[ -s "$config" ]]; then
        # Rebuild binaire xcursor
        xcursorgen "$config" "$output_bin" 2>/dev/null && \
            echo -ne "." || {
            warn "xcursorgen échoué pour $cursor_name — copie directe"
            cp "$cursor_bin" "$output_bin"
        }
    else
        warn "$cursor_name : config vide — copie directe"
        cp "$cursor_bin" "$output_bin"
    fi
}

# ── Pipeline principal ────────────────────────────────────────────
main() {
    echo -e "${M}"
    echo "  ██████╗ ██████╗ ██╗███╗   ███╗ ██████╗ ██╗██████╗ ███████╗"
    echo "  ██╔════╝ ██╔══██╗██║████╗ ████║██╔═══██╗██║██╔══██╗██╔════╝"
    echo "  ██║  ███╗██████╔╝██║██╔████╔██║██║   ██║██║██████╔╝█████╗  "
    echo "  ██║   ██║██╔══██╗██║██║╚██╔╝██║██║   ██║██║██╔══██╗██╔══╝  "
    echo "  ╚██████╔╝██║  ██║██║██║ ╚═╝ ██║╚██████╔╝██║██║  ██║███████╗"
    echo "   ╚═════╝ ╚═╝  ╚═╝╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═╝╚═╝  ╚═╝╚══════╝"
    echo -e "${C}                 Cursor Theme Builder  v2${N}"
    echo ""

    check_deps

    [[ -d "$SRC_THEME/cursors" ]] || err "Source non trouvée : $SRC_THEME\n  → Lance d'abord la v1 pour télécharger l'archive"

    # Prépare les dossiers de build
    rm -rf "$WORK_DIR/extracted" "$WORK_DIR/build/$THEME_NAME"
    mkdir -p "$WORK_DIR/build/$THEME_NAME/cursors"

    # Compte les curseurs à traiter (fichiers réels, pas symlinks)
    local cursors=()
    while IFS= read -r -d '' f; do
        cursors+=("$f")
    done < <(find "$SRC_THEME/cursors" -maxdepth 1 -type f -print0)

    local total=${#cursors[@]}
    log "Traitement de $total curseurs (extract → recolor → rebuild)..."
    echo ""

    local i=0
    for cursor_bin in "${cursors[@]}"; do
        process_cursor "$cursor_bin"
        ((i++))
    done
    echo ""

    # Copie des symlinks
    log "Copie des symlinks..."
    find "$SRC_THEME/cursors" -maxdepth 1 -type l | while read -r lnk; do
        local lnk_name target
        lnk_name=$(basename "$lnk")
        target=$(readlink "$lnk")
        ln -sf "$target" "$WORK_DIR/build/$THEME_NAME/cursors/$lnk_name" 2>/dev/null || true
    done
    ok "Symlinks copiés"

    # index.theme
    cat > "$WORK_DIR/build/$THEME_NAME/index.theme" << EOF
[Icon Theme]
Name=Phinger Cursors Grimoire
Comment=Grimoire cursor theme — tons chauds sombres, rose-violet, orange
Example=default
Inherits=hicolor
EOF
    ok "index.theme créé"

    # Installation user
    log "Installation dans $INSTALL_DIR..."
    rm -rf "$INSTALL_DIR"
    cp -r "$WORK_DIR/build/$THEME_NAME" "$INSTALL_DIR"
    ok "Installé dans $INSTALL_DIR"

    # Dotfiles
    if [[ -d "$DOTFILES_DIR" ]]; then
        log "Copie dans dotfiles..."
        mkdir -p "$DOTFILES_DIR/themes/grimoire-cursors"
        cp -r "$INSTALL_DIR/." "$DOTFILES_DIR/themes/grimoire-cursors/"
        ok "Dotfiles mis à jour"
    fi

    echo ""
    echo -e "${M}╔══════════════════════════════════════════════╗${N}"
    echo -e "${M}║    🔮 Grimoire Cursors v2 — Terminé !       ║${N}"
    echo -e "${M}╚══════════════════════════════════════════════╝${N}"
    echo ""
    echo -e "  Thème : ${C}$THEME_NAME${N}"
    echo -e "  Installé : ${C}$INSTALL_DIR${N}"
    echo ""
    echo -e "${W}Activation :${N}"
    echo -e "  ${Y}hyprctl reload${N}"
    echo -e "  ${Y}nwg-look${N}  →  sélectionner $THEME_NAME"
    echo ""
    echo -e "${W}SDDM :${N}"
    echo -e "  ${Y}sudo cp -r $INSTALL_DIR /usr/share/icons/${N}"
    echo ""
    echo -e "${W}Dotfiles :${N}"
    echo -e "  ${Y}cd ~/dotfiles && git add themes/grimoire-cursors && git commit -m \"feat: curseur Grimoire v2\"${N}"
    echo ""
}

main "$@"
