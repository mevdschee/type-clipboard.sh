#!/bin/bash

# Filename: type-clipboard.sh
# Description: Type the contents of the clipboard into a selected window (X11 only)
# Version: 1.0 (2025-08-28)
# Author: Maurits van der Schee (maurits@vdschee.nl)
# License: MIT

# Detect Wayland and exit if present
if [ -n "$WAYLAND_DISPLAY" ]; then
    echo "Error: Wayland is not supported by this script."
    exit 1
fi

# Parse first argument for help/install/remove actions
target_dir="/usr/local/bin"
target_file="$target_dir/type-clipboard"
desktop_dir="$HOME/.local/share/applications"
if [[ "$desktop_dir" == "/root/.local/share/applications" ]]; then
    desktop_dir="/usr/share/applications"
fi
desktop_file="$desktop_dir/type-clipboard.desktop"

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    cat <<EOF
Usage: $(basename "$0") [install-binary|remove-binary|install-shortcut|remove-shortcut|-h|--help]

install-binary    Install this script to $target_dir
remove-binary     Remove script from $target_dir
install-shortcut  Install shortcut to $desktop_dir
remove-shortcut   Remove shortcut from $desktop_dir
-h, --help        Show this help message

If no argument is given, the script will type clipboard contents into a selected window (X11 only).
EOF
    exit 0
elif [[ "$1" == "install-binary" ]]; then
    if cp -- "$0" "$target_file" && chmod +x "$target_file"; then
        echo "Installed to $target_file"
        exit 0
    fi
    if [ -z "$SUDO_USER" ]; then
        echo "Hint: Try running with sudo."
    fi
    exit 1
elif [[ "$1" == "remove-binary" ]]; then
    if rm "$target_file"; then
        echo "Removed $target_file"
        exit 0
    fi
    if [ -z "$SUDO_USER" ]; then
        echo "Hint: Try running with sudo."
    fi
    exit 1
elif [[ "$1" == "install-shortcut" ]]; then
    cat > "$desktop_file" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=type-clipboard
Comment=Type the contents of the clipboard into a selected window
Exec=type-clipboard
Icon=autokey
Path=
Terminal=false
StartupNotify=false
EOF
    if [[ $? -eq 0 ]]; then
        update-desktop-database "$desktop_dir" >/dev/null 2>&1
        echo "Shortcut installed to $desktop_file"
        exit 0
    fi
    exit 1
elif [[ "$1" == "remove-shortcut" ]]; then
    if rm "$desktop_file"; then
        update-desktop-database "$desktop_dir" >/dev/null 2>&1
        echo "Removed shortcut $desktop_file"
        exit 0
    fi
    exit 1
fi

# Check for required commands
missing=()
for cmd in xclip zenity xdotool; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        missing+=("$cmd")
    fi
done

# Install missing packages
if (( ${#missing[@]} )); then
    pkgs=$(IFS=,; echo "${missing[*]}")
    # Detect package manager
    if command -v apt >/dev/null 2>&1; then
        install_cmd="sudo apt install $pkgs"
    elif command -v dnf >/dev/null 2>&1; then
        install_cmd="sudo dnf install $pkgs"
    elif command -v yum >/dev/null 2>&1; then
        install_cmd="sudo yum install $pkgs"
    elif command -v pacman >/dev/null 2>&1; then
        install_cmd="sudo pacman -Syu $pkgs"
    elif command -v zypper >/dev/null 2>&1; then
        install_cmd="sudo zypper install $pkgs"
    else
        install_cmd="sudo <your package manager> install $pkgs"
    fi
    show_cmd="echo 'Run the following command to install missing dependencies:'; echo; echo '$install_cmd'; echo; echo 'Close the terminal and run again after installation.'; exec bash"
    # Detect if running in a visible terminal window
    if [ -t 1 ] && [ "$TERM" != "dumb" ]; then
        eval "$show_cmd"
    else
        # Try to open a new terminal window to show the install command and shell
        term_cmd=""
        if command -v x-terminal-emulator >/dev/null 2>&1; then
            term_cmd="x-terminal-emulator"
        elif command -v gnome-terminal >/dev/null 2>&1; then
            term_cmd="gnome-terminal"
        elif command -v konsole >/dev/null 2>&1; then
            term_cmd="konsole"
        elif command -v xfce4-terminal >/dev/null 2>&1; then
            term_cmd="xfce4-terminal"
        elif command -v lxterminal >/dev/null 2>&1; then
            term_cmd="lxterminal"
        elif command -v xterm >/dev/null 2>&1; then
            term_cmd="xterm"
        fi
        if [[ -n "$term_cmd" ]]; then
            "$term_cmd" -e "bash -c \"$show_cmd\""
        else
            eval "$show_cmd"
        fi
    fi
    exit 1
fi

# Detect X11 and exit with error if not present
if [ -z "$DISPLAY" ]; then
    echo "Error: This script must be run inside an X11 session."
    exit 1
fi

# Select window and type using xdotool
win=$(xdotool selectwindow 2>/dev/null)
if [[ $? -ne 0 || -z "$win" ]]; then
    echo "Error: Failed to select window."
    exit 1
fi
xdotool windowfocus --sync $win
if [[ $? -ne 0 ]]; then
    echo "Error: Failed to focus window."
    exit 1
fi
# Use sentinel to avoid stripping whitespace
sentinel="__END_OF_CLIPBOARD__"
text=$(xclip -selection clipboard -o; printf "$sentinel")
text="${text%$sentinel}"
# Check for multiline and allow editing using zenity
if [[ "$text" == *$'\n'* ]]; then
    text=$(zenity --text-info --editable --width=600 --height=400 --title="Edit clipboard text before typing" --filename=<(echo -n "$text"))
    if [[ $? -ne 0 ]]; then
        echo "Error: Text editing cancelled."
        exit 1
    fi
    # Replace newlines with carriage returns for xdotool
    echo "[$text]"
    text=$(echo -n "$text" | tr '\n' '\r')
    echo "[$text]"    
fi


# Type the text
echo -n "$text" | xdotool type --clearmodifiers --delay 25 --window $win --file -
