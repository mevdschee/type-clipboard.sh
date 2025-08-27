# type-clipboard.sh

Type the contents of the clipboard into a selected window (X11 only).

## Requirements

- X11 session (not Wayland)
- `xdotool` (for window selection and typing)
- `xclip` (for clipboard access)
- `zenity` (for multiline editing/confirmation)

Install dependencies on:

- **Debian/Ubuntu:** `sudo apt install xdotool xclip zenity`
- **Fedora:** `sudo dnf install xdotool xclip zenity`
- **Arch/Manjaro:** `sudo pacman -Syu xdotool xclip zenity`

## Usage

```
type-clipboard.sh [install-binary|remove-binary|install-shortcut|remove-shortcut|-h|--help]
```

- `install-binary`    Install this script to `/usr/local/bin/type-clipboard`
- `remove-binary`     Remove script from `/usr/local/bin/type-clipboard`
- `install-shortcut`  Install shortcut to `~/.local/share/applications/type-clipboard.desktop`
- `remove-shortcut`   Remove shortcut from `~/.local/share/applications/type-clipboard.desktop`
- `-h`, `--help`      Show help message

If no argument is given, the script will prompt you to select a window and type the clipboard contents into it. If the clipboard contains multiple lines, you can edit the text before typing.

## License

MIT License (see LICENSE file)
