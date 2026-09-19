# Feel Box

A rectangle in an empty room that feels good to move.

A tuning exercise used to learn the basic game development concepts. The same character controller built seven times, from a naive version that feels like dragging an icon around a desktop to one with weight, forgiveness and consequence.

Built in **Godot 4.7** with GDScript.

---

## Run it

Open the project in Godot and press <kbd>F5</kbd>.

| Key                         | Action                 |
| --------------------------- | ---------------------- |
| <kbd>A</kbd> / <kbd>←</kbd> | Move left              |
| <kbd>D</kbd> / <kbd>→</kbd> | Move right             |
| <kbd>Space</kbd>            | Jump (hold for height) |

---

## The versions

Each is a git commit. Check any of them out and play.

|        | What it adds                                              |
| ------ | --------------------------------------------------------- |
| **v0** | Direct velocity, fixed jump, one gravity value            |
| **v1** | Acceleration and friction, separate ground and air values |
| **v2** | Variable jump height — release early, rise less           |
| **v3** | Asymmetric gravity, with reduced gravity near the apex    |
| **v4** | Coyote time and jump buffering                            |
| **v5** | Squash and stretch on jump and landing                    |
| **v6** | Camera lead, landing dust, screen shake on hard landings  |

The point is the comparison. Check out v0, play for a minute, then v6, then v0 again.

---

## Files

```
player.gd      the controller — everything interesting is here
player.tscn    CharacterBody2D + collision + visual + camera + dust
world.tscn     a floor and a player
```

---

## Tuning

Every constant sits at the top of `player.gd`. They're worth breaking on purpose:

| Constant            | Try it at       | To feel                                           |
| ------------------- | --------------- | ------------------------------------------------- |
| `ACCEL`             | `400` / `20000` | Syrup vs. teleporting                             |
| `JUMP_CUT`          | `0.2` / `0.7`   | Sharp vs. barely-there jump control               |
| `APEX_GRAVITY_MULT` | comment it out  | How much the hang time was doing                  |
| `COYOTE_TIME`       | `0.5`           | The mechanism becoming visible                    |
| `HARD_LANDING`      | `0`             | Why shake on every landing stops meaning anything |

Change one at a time and play after each.

---

## Numbers worth knowing

At the default settings: jump velocity 520, rising gravity 1500.

- Time to apex: **~0.37s**
- Total airtime: **~0.74s**
- Peak height: **~97px** — about three box-heights
