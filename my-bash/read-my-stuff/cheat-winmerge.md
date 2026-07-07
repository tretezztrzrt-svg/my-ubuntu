# WinMerge Alternative for Ubuntu

Ubuntu users can use several graphical and command-line diff tools. Here are good alternatives and some useful scripts.

## Graphical tools

- **Meld**
  - Install: `sudo apt install meld`
  - Launch: `meld file1 file2` or `meld dir1 dir2`

- **KDiff3**
  - Install: `sudo apt install kdiff3`
  - Launch: `kdiff3 file1 file2`

- **Beyond Compare** (proprietary)
  - Download from official site and install the .deb

## Command-line alternatives

- **diff**
  - Basic compare: `diff -u file1 file2`

- **colordiff**
  - Install: `sudo apt install colordiff`
  - Use: `colordiff -u file1 file2`

- **vimdiff**
  - Built-in Vim diff mode: `vimdiff file1 file2`

## Simple script for unified diff

Save the following as `diffview`, make it executable with `chmod +x diffview`, and run `./diffview file1 file2`:

```bash
#!/bin/bash
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 file1 file2"
  exit 1
fi

colordiff -u "$1" "$2" | less -R
```

## Git-friendly diff

For repo comparisons, use:

```bash
git difftool --tool=meld
```
