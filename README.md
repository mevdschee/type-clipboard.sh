# type-clipboard.sh

Type the contents of the clipboard into a selected window (X11 only, Wayland not supported).

The script will prompt you to select a window before it types the clipboard contents into it.

If the clipboard contains multiple lines, you can edit the text before typing using an edit window.

## Requirements

- X11 session (not Wayland)
- `xdotool` (for window selection and typing)
- `xclip` (for clipboard access)
- `yad` (for multiline editing/confirmation)

When you run the script for the first time, it will check for these dependencies and suggest how to install them if they are missing.

Install dependencies on:

- **Debian/Ubuntu:** `sudo apt install xdotool xclip yad`
- **Fedora:** `sudo dnf install xdotool xclip yad`
- **Arch/Manjaro:** `sudo pacman -Syu xdotool xclip yad`
- **openSUSE:** `sudo zypper install xdotool xclip yad`
- **CentOS/RHEL:** `sudo yum install xdotool xclip yad` 

**Note:** CentOS/RHEL requires EPEL repository: `sudo yum install epel-release`

## Usage

```
bash type-clipboard.sh [install-script|remove-script|install-shortcut|remove-shortcut|-h]
```

- `install-script`    - Install this script to `/usr/local/bin/type-clipboard` (requires superuser privileges)
- `remove-script`     - Remove script from `/usr/local/bin/type-clipboard` (requires superuser privileges)
- `install-shortcut`  - Install shortcut to `/usr/share/applications` (requires superuser privileges)
- `remove-shortcut`   - Remove shortcut to `/usr/share/applications` (requires superuser privileges)
- `-h`, `--help`      - Show help message

**Note:** You may need to prepend `sudo` to the script to execute it with superuser privileges.

After installing the shortcut, the application should be easy to add to your menu or panel. The shortcut database is updated automatically and the application will appear as "type-clipboard".

## License

MIT License (see LICENSE file)
