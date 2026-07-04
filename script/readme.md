# Ubuntu Command-Line Rulebook
### When to use Aliases, Functions, Scripts, and Nautilus Context Menus

Stop overthinking the distinction. The line is **not** about whether you touch files, directories, or variables. The line is about **complexity, reusability, and execution environment**.

---

## 1. ALIASES
**Use for:** Shortcuts, defaults, and fixed flags.

**The Golden Rule:**
If you have to type `$1`, `$2`, or `$@` inside it, **you are doing it wrong**. Aliases do not handle arguments gracefully across all shells.

**Good Examples:**
- `alias ll='ls -alF'`
- `alias gs='git status'`
- `alias update='sudo apt update && sudo apt upgrade -y'`
- `alias ..='cd ..'`

**The Hard Line:**
The moment you need to pass a dynamic value, abandon the alias. That is a job for a function.

---

## 2. FUNCTIONS
**Use for:** Short, logical blocks that accept arguments.

**The Golden Rule:**
Keep functions in your `.bashrc` (or `.bash_aliases`) **only if** they fit on your screen without scrolling (≤ 5 lines). Use them for combining commands where the output of one depends on the input of another.

**Good Examples:**
- `mkcd() { mkdir -p "$1" && cd "$1"; }`
- `backup() { cp "$1" "$1.bak" && echo "Backed up $1"; }`
- `extract() { tar -xzf "$1"; }` (with added logic for different archive types)

**The Hard Line:**
If your function contains:
- `if`/`then`/`else` with more than 2 conditions,
- `for` or `while` loops,
- Pipelines with `grep`, `awk`, or `find` that are longer than a single line,

...it is too large for your shell configuration. Move it to an external script.

---

## 3. EXTERNAL SCRIPTS
**Use for:** Complexity, portability, and automation outside your terminal.

**The Golden Rule:**
Place scripts in `~/bin/` (ensure it is in your `$PATH`) or `/usr/local/bin/`. Always start with a proper shebang (`#!/bin/bash` or `#!/usr/bin/env python3`).

**When to absolutely use a script:**
- Your logic exceeds 5–10 lines.
- You want to run the same tool from multiple directories or machines.
- You need to use a different interpreter (Python, Perl, AWK).
- You want to source the script from another application.

**CRON JOBS – The Non-Negotiable Rule:**
**Always** use an external script for cron. Cron runs in a stripped-down environment. Aliases and functions defined in your `.bashrc` **do not exist** inside cron. A script with absolute paths is the only reliable approach.

---

## 4. NAUTILUS CONTEXT MENU (Right-Click Actions)
**Use for:** Quick GUI-based file operations that save you mouse clicks.

**The Golden Rule:**
Store these scripts in `~/.local/share/nautilus/scripts/`. Make them executable. They will appear in the right-click menu under "Scripts".

**What belongs here:**
- "Resize this image to 800x600."
- "Generate an MD5 hash of this file."
- "Open this folder in VS Code."
- "Convert this MP4 to MP3."

**The Hard Line – Environment Isolation:**
Nautilus **does not** load your `.bashrc`, `.bash_aliases`, or custom functions. Therefore:
- Do **not** rely on your personal aliases inside these scripts.
- Always use **absolute paths** to binaries (e.g., `/usr/bin/convert` instead of just `convert`).
- Keep the action **simple**. Avoid scripts that require interactive input (like typing a password or selecting from a list), because the GUI hides stdout/stderr. If it fails, you will never see the error.

---

## The Ultimate Decision Filter

When you cannot decide, run your use-case through these three questions in order:

1. **Does this need to run outside my interactive terminal?**  
   *(e.g., Cron, GUI click, systemd timer, or another user's session)*  
   → **Yes:** Use an **External Script**.  
   → **No:** Proceed to question 2.

2. **Does the command accept dynamic arguments or contain logic (`if`/`for`)?**  
   → **No** (just static flags): Use an **Alias**.  
   → **Yes** (needs `$1`, `$2`, or branching): Proceed to question 3.

3. **Is the entire logic shorter than 5 lines of clean code?**  
   → **Yes:** Use a **Function** inside `.bashrc`.  
   → **No:** Use an **External Script**.

---

## The Ecosystem: Other Tools in Your Sphere

These live adjacent to the four above. Know when to reach for them.

- **`.desktop` launcher files** (`~/.local/share/applications/`):  
  For GUI application entries (Dash / Alt+F2). Not for terminal commands. Use `Exec=` with **absolute paths**. Perfect for wrapping scripts into clickable icons.

- **Cron vs. systemd timers**:  
  Cron for simple, recurring schedules (`@daily`, `*/5 * * * *`). systemd timers for complex dependencies (e.g., "run after network is up") and better logging. **Both** must call external scripts – never aliases or functions.

- **Shell config files** – the loading order trap:  
  - `~/.profile` / `~/.bash_profile` → login shells, set `PATH` and environment variables.  
  - `~/.bashrc` / `~/.zshrc` → interactive shells, set aliases, functions, and `PS1`.  
  **Hard line:** Export `PATH` in `.profile`; define aliases in `.bashrc`. Do not mix them up, or GUI sessions will miss your `PATH`.

- **`PATH` & shell completion**:  
  Drop custom scripts into `~/bin/` – Ubuntu often adds it to `PATH` automatically. Install `bash-completion` and write a small completion file for your custom commands; this makes them feel native (tab-working).

- **Wrapper commands**:  
  Tiny scripts (≤ 3 lines) in your `PATH` that call your real script with sane defaults or environment variables. Useful for overriding system commands without editing the original.

- **`make` / task runners** (optional):  
  Overkill for single scripts. Use `make` only when your workflow has **dependencies** (e.g., "convert A → B, then B → C") or you need to rerun only changed files. Otherwise, a plain bash script with functions is simpler.

---

## Final Pro-Tip: The "Script" Default
When in doubt, **write a script**. Scripts are globally reusable, testable, debuggable, and work everywhere. Aliases and functions are convenience tools for your fingers; scripts are engineering tools for your system.

---
## info: dir `check-info` → scripts funny to run once...