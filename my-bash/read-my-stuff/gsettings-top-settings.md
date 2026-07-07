# Praktische gsettings-Befehle für GNOME

Das hier ist eine kurze, nützliche Liste für Alltagseinstellungen – ohne viel Eyecandy, außer Dark Mode.

## Fenster & Arbeitsfläche

| Ziel | Befehl |
| --- | --- |
| Fensterbuttons rechts | `gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"` |
| Fensterbuttons links | `gsettings set org.gnome.desktop.wm.preferences button-layout "close,minimize,maximize:"` |
| Fenster beim Start zentrieren | `gsettings set org.gnome.mutter center-new-windows true` |
| Animationen aus | `gsettings set org.gnome.desktop.interface enable-animations false` |

## Oberfläche & Dark Mode

| Ziel | Befehl |
| --- | --- |
| Dark Mode aktivieren | `gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'` |
| Dark Mode für GNOME-Oberfläche | `gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'` |
| Akku-Prozent anzeigen | `gsettings set org.gnome.desktop.interface show-battery-percentage true` |
| Datum in der Uhr anzeigen | `gsettings set org.gnome.desktop.interface clock-show-date true` |

## Maus & Touchpad

| Ziel | Befehl |
| --- | --- |
| Natürliches Scrollen | `gsettings set org.gnome.desktop.peripherals.mouse natural-scroll true` |
| Tap-to-Click aktivieren | `gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true` |
| Mauszeiger etwas schneller machen | `gsettings set org.gnome.desktop.peripherals.mouse speed 0.3` |

## Tastatur & Shortcuts

| Ziel | Befehl |
| --- | --- |
| Screenshot-Kürzel deaktivieren | `gsettings set org.gnome.shell.keybindings screenshot '["disabled"]'` |
| Tastenkürzel eines Schemas ansehen | `gsettings list-keys org.gnome.shell.keybindings` |
| Aktuelles Screenshot-Kürzel prüfen | `gsettings get org.gnome.shell.keybindings screenshot` |

## Dateien & Nautilus

| Ziel | Befehl |
| --- | --- |
| Versteckte Dateien anzeigen | `gsettings set org.gnome.nautilus.preferences show-hidden-files true` |
| Pfad als Text statt Buttons anzeigen | `gsettings set org.gnome.nautilus.preferences always-use-location-entry true` |
| Sortierung nach Dateityp | `gsettings set org.gnome.nautilus.preferences default-sort-order 'type'` |

## Extra-Tipps

| Ziel | Befehl |
| --- | --- |
| Automatische Bildschirmhelligkeit deaktivieren | `gsettings set org.gnome.desktop.a11y.keyboard enable false` |
| Touchpad nur bei Bedarf aktivieren | `gsettings set org.gnome.desktop.peripherals.touchpad send-events 'disabled-on-external-mouse'` |
| Fenster über alle Arbeitsflächen ziehen | `gsettings set org.gnome.mutter workspaces-only-on-primary false` |

## Grundbefehle

| Zweck | Befehl |
| --- | --- |
| Wert auslesen | `gsettings get <schema> <key>` |
| Wert setzen | `gsettings set <schema> <key> <wert>` |
| Wert zurücksetzen | `gsettings reset <schema> <key>` |
| Alle Keys eines Schemas zeigen | `gsettings list-keys <schema>` |
| Alles durchsuchen | `gsettings list-recursively | grep "suchbegriff"` |

## Tipp

Wenn du unsicher bist, hilft oft `gsettings list-recursively | grep "suchbegriff"` sehr schnell, um die passende Einstellung zu finden.
