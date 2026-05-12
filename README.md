# SparkBlox MC SMP

## Server Info
- **Version:** Paper 1.21.1
- **RAM:** 4 GB
- **Java:** 21+

## Connection Addresses
- **Java Edition:** `spblox.playit.plus`
- **Bedrock Edition:** `sparkblox.playit.plus` port `1052`

## Installed Plugins
| Plugin | Purpose |
|--------|---------|
| Geyser-Spigot | Allows Bedrock players to join the Java server |
| Floodgate-Spigot | Lets Bedrock players join without a Java account |
| GrimAC | Anti-cheat (movement, combat, packet checks) |

## How to Start
1. Make sure the **playit.gg agent** is running
2. Double-click **`start.bat`**
3. Wait for the server to finish loading (you'll see "Done!" in the console)
4. Share the connection addresses above with your players

## Anti-Xray
Paper has **built-in anti-xray** support. After the first server start, edit:
- `config/paper-world-defaults.yml`
- Under `anticheat.anti-xray`, set `enabled: true` and configure the mode (mode 1 or 2)

## Geyser Config
After first start, check `plugins/Geyser-Spigot/config.yml`:
- `bedrock.port` should be `19132` (playit.gg tunnel points here)
- `remote.port` should be `25565`

## Notes
- `allow-flight` is set to `true` because GrimAC handles fly-hack detection
- `enforce-secure-profile` is `false` for Bedrock compatibility
- `online-mode` is `true` — Floodgate handles Bedrock auth separately
