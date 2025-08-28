# type-clipboard.sh

Linux bash script that types the contents of the clipboard into a selected window.

This is for IT professionals that need to type long passwords or keys into remote consoles.

The script will prompt you to select a window before it types the clipboard contents into it.

If the clipboard contains multiple lines, you can edit the text before typing using an edit window.

## Requirements

- Linux X11 session (not Wayland)
- `xdotool` (for window selection and typing)
- `xclip` (for clipboard access)
- `yad` (for multiline editing/confirmation)

When you run the script for the first time, it will check for these dependencies and suggest how to install them if they are missing.

## Usage

```
[sudo] bash type-clipboard.sh [install|remove|-h|--help]
```

- `install`       - Install the script and shortcut (requires root privileges)
- `remove`        - Remove the script and shortcut (requires root privileges)
- `-h`, `--help`  - Show help message

**Note:** You may need to prepend `sudo` to the script to execute it with root privileges.

## Files

When installing the script the follow installation paths are used:

- Script: `/usr/local/bin/type-clipboard` 
- Shortcut: `/usr/share/applications/type-clipboard.desktop`

After installing the shortcut, the application should be easy to add to your menu or panel. The shortcut database is updated automatically and the application will appear as "type-clipboard".

## License

MIT License (see LICENSE file)

## Some other tools

- [xdotool-type-clipboard - A simple bash script using xdotool and a delay](https://github.com/POMATu/xdotool-type-clipboard)
- [TypeClipboard - A Windows application written in C#](https://github.com/jlaundry/TypeClipboard)
- [PyTyper - A Python implementation of a clipboard typer](https://github.com/DoingFedTime/PyTyper)
