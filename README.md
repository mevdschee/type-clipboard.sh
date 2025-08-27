# type-clipboard.sh

Type the contents of the clipboard into a selected window (X11 only, Wayland not supported).

The script will prompt you to select a window before it types the clipboard contents into it.

If the clipboard contains multiple lines, you can edit the text before typing using an edit window.

## Requirements

- X11 session (not Wayland)
- `xdotool` (for window selection and typing)
- `xclip` (for clipboard access)
- `zenity` (for multiline editing/confirmation)

When you run the script for the first time, it will check for these dependencies and suggest how to install them if they are missing.

Install dependencies on:
- **Debian/Ubuntu:** `sudo apt install xdotool xclip zenity`
- **Fedora:** `sudo dnf install xdotool xclip zenity`
- **Arch/Manjaro:** `sudo pacman -Syu xdotool xclip zenity`

## Usage

```
bash type-clipboard.sh [install-binary|remove-binary|install-shortcut|remove-shortcut|-h]
```

- `install-binary`    Install this script to `/usr/local/bin/type-clipboard` (requires superuser privileges)
- `remove-binary`     Remove script from `/usr/local/bin/type-clipboard` (requires superuser privileges)
- `install-shortcut`  Install shortcut globally (requires superuser privileges) or locally
- `remove-shortcut`   Remove shortcut globally (requires superuser privileges) or locally
- `-h`, `--help`      Show help message

**Note:** Installing or removing the binary in `/usr/local/bin` requires superuser privileges. Use `sudo bash type-clipboard.sh install-binary` or `sudo bash type-clipboard.sh remove-binary` to avoid permission errors.

After installing the shortcut, the application should be easy to add to your menu or panel. The shortcut database is updated automatically and the application will appear as "type-clipboard".

## License

MIT License (see LICENSE file)
