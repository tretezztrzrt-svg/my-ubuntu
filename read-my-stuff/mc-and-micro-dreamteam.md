# Why You Should Use `micro` and `mc` (and two more tools to make your admin life easier)

Look, I get it. You're new, you're lazy, and you just want shit to work without reading a 500-page manual. Same here. So let's cut the crap.

---

## `micro` – The Text Editor That Doesn't Hate You

**What it is:** A terminal-based text editor.

**Why you should use it instead of `nano`:**

Let's be real – `nano` is from 1999. It's old, it's clunky, and the shortcuts make zero sense. You have to press `Ctrl+O` to save instead of `Ctrl+S`. Who thought that was a good idea?

`micro` fixes all that bullshit:

- **Normal keyboard shortcuts** – `Ctrl+S` to save, `Ctrl+C` to copy, `Ctrl+V` to paste, `Ctrl+Z` to undo. Stuff you already know.
- **Mouse support** – You can click, highlight, and scroll with your mouse like a normal person.
- **Syntax highlighting** for over 130 languages – so config files actually make sense.
- **Split-screen** – edit two files side by side.
- **Plugins** – if you ever feel like customizing shit.
- **Single binary, no dependencies** – just download and run.

**Install it:**

```bash
sudo apt install micro   # Ubuntu/Debian
```

## `mc` (Midnight Commander) – The File Manager That Saves Your Sanity

**What it is:** A terminal-based file manager with a dual-pane interface.

**Why you should use it instead of `ls`/`cd`/`cp`/`mv` hell:**

Typing `ls`, `cd`, `cp`, `mv`, `rm` over and over gets old fast. `mc` gives you a visual file manager right in your terminal – like Windows Explorer but for people who don't hate themselves.

**What it does:**

- **Dual-pane view** – two folders side by side. Copy/move files between them with a couple of keystrokes.
- **Mouse support** – click to open folders, select files, use menus.
- **Built-in text editor** (`mcedit`) with syntax highlighting – edit files without leaving `mc`.
- **Built-in file viewer** – press `F3` to peek inside a file.
- **Built-in diff tool** (`mcdiff`) – compare files side by side.
- **Virtual filesystems** – browse inside `.tar.gz` or `.zip` files without extracting them. Connect to remote servers via FTP/SSH right from the file manager.
- **Batch operations** – tag multiple files with `Insert` and act on all of them at once.
- **Custom user menu** (`F2`) – automate repetitive tasks with your own scripts.

**Install it:**

```bash
sudo apt install mc   # Ubuntu/Debian
```
