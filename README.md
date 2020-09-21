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
| `cow`               | Changes player model to Nali Cow. Skin is randomised.                                                                                              |
| `nali`              | Changes player model to Nali Priest. Skin is randomised.                                                                                           |
| `skaarj`            | Changes player model to Skaarj Hybrid. Skin is randomised.                                                                                         |
| `<class>`           | Attempts to change player model to the specified class. For example, `UnrealI.Squid` will change to Squid model. Class names are case insensitive. |
| `p <name> <action>` | Targets a player matching `<name>` and performs the morph action on them. `<name>` can be a partial match, e.g. "sap" for "Sapphire".              |
