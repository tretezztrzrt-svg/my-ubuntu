# gsettings, dconf, and systemd — quick reference

## At a glance
- **gsettings**: high-level API / CLI for GNOME/GSettings. Schema‑aware and type‑checked. Good for single-key changes and scripting per‑user settings.
- **dconf**: low‑level storage/backend for GSettings (and GUI `dconf-editor`). Good for inspection, bulk dump/load, backups, and system defaults/locks. More powerful — and more dangerous — because you can bypass schema validation.
- **systemd**: init/system and service manager used by modern Ubuntu. Manages boot, services (units), timers, logging (`journald`), and dependencies.

---

## gsettings

**What:** CLI binding to GSettings (GNOME’s settings API). Uses schemas to validate types.

**When to use:** one‑off tweaks, scripts that change a few keys, querying current values.

**Key commands and examples:**

```bash
# list installed schemas
gsettings list-schemas

# list keys in a schema
gsettings list-keys org.gnome.desktop.interface

# get a value
gsettings get org.gnome.desktop.interface gtk-theme

# set a value (type-checked)
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'

# reset a key to default
gsettings reset org.gnome.desktop.interface gtk-theme
```

**Notes:**
- Safer than writing raw GVariant literals. Good for automation targeted at a user session.
- Some changes require re-login or GNOME Shell restart (Alt+F2 → r).

---

## dconf

**What:** low-level key/value database (binary DB) used by GSettings; tools: `dconf` (CLI) and `dconf-editor` (GUI).

**When to use:** bulk operations (dump/load), backups, migrating settings, setting system defaults and locks via `/etc/dconf/db/`, and low‑level inspection.

**Key commands and examples:**

```bash
# dump a tree
dconf dump /org/gnome/ > gnome-settings.ini

# load a tree
dconf load /org/gnome/ < gnome-settings.ini

# write a single key (GVariant literal — quoting matters)
dconf write /org/gnome/desktop/interface/gtk-theme "'Adwaita-dark'"

# reset a key or tree
dconf reset /org/gnome/desktop/interface/gtk-theme
dconf reset -f /org/gnome/desktop/interface/   # recursive

# GUI
dconf-editor
```

**Admin/system defaults and locks:**
- System defaults are placed under `/etc/dconf/db/*` (example: `/etc/dconf/db/local.d/` and `/etc/dconf/db/local.d/locks`). After adding files, run:

```bash
sudo dconf update
```

- Use `locks` files to prevent users from changing keys.

**Cautions:**
- `dconf write` bypasses some schema checks if you craft incorrect GVariant literals — back up first:

```bash
dconf dump / > ~/dconf-backup.ini
```

---

## systemd

**What:** init system and service manager (PID 1). Handles units (`.service`, `.socket`, `.timer`, `.target`), boot ordering, logging (`journalctl`), and more.

**When to use:** managing services, enabling at boot, troubleshooting boot problems, setting timers, and creating custom system services.

**Common commands and examples:**

```bash
# check what runs as PID 1
ps -p 1 -o comm=

# show service status
systemctl status sshd.service

# start/stop/restart a service (system scope, requires root)
sudo systemctl start apache2.service
sudo systemctl stop apache2.service
sudo systemctl restart apache2.service

# enable/disable at boot
sudo systemctl enable --now my.service
sudo systemctl disable my.service

# view logs
journalctl -u my.service         # by unit
journalctl -b                    # current boot
journalctl -f                    # follow (like tail -f)

# reload unit files after editing
sudo systemctl daemon-reload

# mask a service (prevent it from starting)
sudo systemctl mask some.service
```

**Unit file locations:**
- System units: `/lib/systemd/system/` and `/etc/systemd/system/`
- Per-user units: `~/.config/systemd/user/` (use `systemctl --user`)

**Cautions:**
- System units require root; user units run in the user session.
- Prefer drop‑ins (`/etc/systemd/system/<unit>.d/*.conf`) for overrides instead of editing packaged unit files directly.

---

## How they relate
- `gsettings` ↔ `dconf`: `gsettings` is the high‑level API and CLI; `dconf` is the backend DB and low‑level tool. They operate on the same GNOME settings data.
- `systemd` is unrelated to GNOME settings: it manages services and boot; settings tools (`gsettings`/`dconf`) are about desktop configuration.

---

## Practical recommendations
- Everyday desktop user: use the Settings app or `gsettings` for safe changes.
- Power user / migration: use `dconf dump`/`load` for backups and bulk restores.
- System administrator: define defaults and locks under `/etc/dconf/db/` and run `dconf update`; use `systemd` unit files and drop‑ins to manage services.
- Scripting: prefer `gsettings` for per‑key scripts, `dconf` for tree import/export tasks, and `systemctl` for service automation.

---

If you want, I can produce a printable one‑page cheat‑sheet, generate example dconf profiles for system defaults and locks, or craft a script that uses `gsettings` to configure a new Ubuntu user.