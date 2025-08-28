#!/bin/bash

# Filename: type-clipboard.sh
# Description: Type the contents of the clipboard into a selected window
# Version: 1.0 (2025-08-28)
# Author: Maurits van der Schee (maurits@vdschee.nl)
# License: MIT

# Detect Wayland and exit if present

# Set type_tool variable based on display server
if [ -n "$WAYLAND_DISPLAY" ]; then
    type_tool="wlrctl"
else
    type_tool="xdotool"
fi

# Wayland not supported yet, exit for now
if [ -n "$WAYLAND_DISPLAY" ]; then
    echo "Error: Wayland is not supported by this script." >&2
    exit 1
fi

# Parse first argument for help/install/remove actions
target_dir="/usr/local/bin"
target_file="$target_dir/type-clipboard"
desktop_dir="/usr/share/applications"
desktop_file="$desktop_dir/type-clipboard.desktop"

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    cat <<EOF
Usage: $(basename "$0") [install|remove|-h|--help]

install     Install this script and create a shortcut
remove      Remove the script and its shortcut
-h, --help  Show this help message

Installation paths:
- script: $target_file
- shortcut: $desktop_file

If no argument is given, the script will:
- allow selecting a window using the left mouse button
- allow editing or cancelling (multiline content only)
- type the clipboard contents into the selected window

EOF
    exit 0
elif [[ "$1" == "install" ]]; then
    # Check for root privileges
    if [ "$EUID" -ne 0 ]; then
        echo "Error: Must be run as root (e.g. using sudo)." >&2
        exit 1
    fi
    # Install script
    cp -- "$0" "$target_file" && chmod +x "$target_file"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to install script." >&2
        exit 1
    fi
    echo "Script installed to $target_file"
    # Install desktop entry
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
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to install shortcut." >&2
        exit 1
    fi
    update-desktop-database "$desktop_dir" >/dev/null 2>&1
    echo "Shortcut installed to $desktop_file"
    exit 0
elif [[ "$1" == "remove" ]]; then
    # Check for root privileges
    if [ "$EUID" -ne 0 ]; then
        echo "Error: Must be run as root (e.g. using sudo)." >&2
        exit 1
    fi
    # Remove script
    rm "$target_file"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to remove script." >&2
        exit 1
    fi
    echo "Removed script from $target_file"
    # Remove desktop entry
    rm "$desktop_file"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to remove shortcut." >&2
        exit 1
    fi
    update-desktop-database "$desktop_dir" >/dev/null 2>&1
    echo "Removed shortcut from $desktop_file"
    exit 0
fi

# Check for required commands
missing=()
for cmd in xclip yad "$type_tool"; do
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

# Detect graphical session and exit with error if not present
if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ]; then
    echo "Error: This script must be run inside a graphical session." >&2
    exit 1
fi

# Use sentinel to avoid stripping whitespace
sentinel="__END_OF_CLIPBOARD__"
text=$(xclip -selection clipboard -o; printf "$sentinel")
text="${text%$sentinel}"
# Check for multiline and allow editing using yad
if [[ "$text" == *$'\n'* ]]; then
    text=$(echo -n "$text" | yad --text-info --editable --width=600 --height=400 --title="Edit clipboard text before typing" --listen --tail && printf "$sentinel")
    if [[ $? -ne 0 ]]; then
        echo "Error: Text editing cancelled." >&2
        exit 1
    fi
    text="${text%$sentinel}"
    # Replace newlines with carriage returns
    text=$(echo -n "$text" | tr '\n' '\r')
fi


# Ask user for delay using yad (default delay 2)
result=$(yad --form --title="Type Clipboard" \
    --field="Delay before typing (seconds)":NUM "2")
if [[ $? -ne 0 || -z "$result" ]]; then
    echo "Error: Input cancelled." >&2
    exit 1
else
    result=(${result//|/ })
    delay="${result[0]}"
fi

# If delay is a positive integer, then sleep for that delay
if [[ "$delay" =~ ^[0-9]+$ ]]; then
    sleep "$delay"
fi

# Select window if xdotool is used
if [[ "$type_tool" == "xdotool" ]]; then
    win=$(xdotool selectwindow 2>/dev/null)
    if [[ $? -ne 0 || -z "$win" ]]; then
        echo "Error: Failed to select window." >&2
        exit 1
    fi
else
    # Wayland: show yad combobox with wlrctl toplevel list
    win_titles=$(wlrctl toplevel list | awk -F'\t' '{print $2}' | grep -v '^$' | tr '\n' '!')
    win_title=$(yad --form --title="Select Wayland Window" --field="Window title":CB "$win_titles")
    win_title="${win_title#|}"
    if [[ -z "$win_title" ]]; then
        echo "Error: No window selected." >&2
        exit 1
    fi
    # Get window id from title
    win=$(wlrctl toplevel list | awk -F'\t' -v t="$win_title" '$2==t {print $1}')
    if [[ -z "$win" ]]; then
        echo "Error: Window not found." >&2
        exit 1
    fi
fi

# Focus window if xdotool is used
if [[ "$type_tool" == "xdotool" ]]; then
    xdotool windowfocus --sync $win
else
    wlrctl toplevel focus "$win"
fi
if [[ $? -ne 0 ]]; then
    echo "Error: Failed to focus window." >&2
    exit 1
fi

# Type if text is non-empty
if [[ -n "$text" ]]; then
    if [[ "$type_tool" == "xdotool" ]]; then   
        echo -n "$text" | xdotool type --clearmodifiers --delay 25 --window $win --file -
    elif [[ "$type_tool" == "wlrctl" ]]; then
        echo -n "$text" | wlrctl type
    fi
fi
