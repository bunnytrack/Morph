# Morph

This mod started out as a small script to "morph" players by changing them into monsters, items, and increasing/decreasing their size (DrawScale).

It has since grown in size with other goofy/fun ideas, including:

* giving other players cheat commands such as "fly", "ghost", and "god"
* making other players send messages and voice/movement taunts
* instant teleporting to crosshairs
* turning players into light sources
* spawning an army of mini Xan bots

This mod was made for the sole purpose of goofing around, and uploaded in the hope that it may help others learn more about UnrealScript.

Made with ❤️.

## Commands

### `mutate morph <action>`
The morph command accepts the following values for `<action>`:

| Action              | Description                                                                                                                                        |
| ---                 | ---                                                                                                                                                |
| `grow`              | Increases the size of any Pawn actor under the sender's crosshairs.                                                                                |
| `shrink`            | Same as above, but decreases size.                                                                                                                 |
| `reset`             | Resets player size and collision.                                                                                                                  |
| `cow`               | Changes player model to Nali WarCow. Skin is randomised.                                                                                              |
| `nali`              | Changes player model to Nali Priest. Skin is randomised.                                                                                           |
| `skaarj`            | Changes player model to Skaarj Hybrid. Skin is randomised.                                                                                         |
| `<class>`           | Attempts to change player model to the specified class. For example, `UnrealI.Squid` will change to Squid model. Class names are case insensitive. |
| `p <name> <action>` | Targets a player matching `<name>` and performs the morph action on them. `<name>` can be a partial match, e.g. "sap" for "Sapphire".              |

---

### `mutate puppet <action>`
As with `morph`, `puppet` can target players using the same `p <name> <action>` syntax. If this is omitted, most actions will be performed on all players in the game.

Valid `<action>` values are:

| Action                               | Description                                                                                                                                        |
| ---                                  | ---                                                                                                                                                |
| `fire`                               | Triggers fire command ("left click" fire).                                                                                                         |
| `altfire`                            | Triggers alternate fire command ("right click" fire).                                                                                              |
| `allammo`                            | Applies the `allammo` cheat (maximum ammo for all weapons).                                                                                        |
| `death`                              | Triggers "feign death" command.                                                                                                                    |
| `jump`                               | Triggers a jump.                                                                                                                                   |
| `suicide`                            | Triggers suicide.                                                                                                                                  |
| `say <message>`                      | Makes player say the specified message.                                                                                                            |
| `speech <type> <index> <call sign> ` | Makes player use the specified speech. View User.ini to see speech commands. "3 16 0" is the "Ha ha ha" taunt for the Male Two voice, for example. |
| `taunt <type>`                       | Makes player use the specified taunt. Default taunt values are `wave`, `thrust`, `taunt1`, and `victory1`.                                         |
| `jumpz <value>`                      | Sets the "JumpZ" (vertical jump height) value. Use "reset" as `<value>` to restore the default JumpZ (325).                                        |
| `shake <duration>`                   | Shakes the screen for `<duration>` seconds. Default duration is 1.                                                                                 |
| `f5 <name>`                          | Sets player's view target to player matching `<name>`. Works for any team colour.                                                                  |

---

### `mutate cheat <name> <cheat>`
Performs a cheat command on the specified player. Useful for giving players "fly" or "ghost" mode without exposing the admin password.

Supported cheat commands are:

* `god`
* `fly`
* `ghost`
* `walk`

---

### `mutate light <action>`
Turns players into light sources (by setting Lighting-related properties).

As with previous commands, `light` can target players using `p <name> <action>`. If this is omitted, the action is applied to the command sender.

| Action               | Description                                                                          |
| ---                  | ---                                                                                  |
| `off`                | Disables lighting.                                                                   |
| `hue <value>`        | Sets hue to `<value>`. Range is 0-255.                                               |
| `brightness <value>` | Sets brightness to `<value>`. Range is 0-255.                                        |
| `saturation <value>` | Sets saturation to `<value>`. Range is 0-255.                                        |
| `<colour>`           | Supported colours are: `red`, `orange`, `yellow`, `green`, `blue`, `purple`, `pink`. |

---

### `mutate tele`
Instantly teleports to the position at the sender's crosshairs.

---

### `mutate helper <action>`
Spawns a mini Xan bot which follows the spawner by default. If `<action>` is `follow <name>`, Xan(s) will follow the specified player.
