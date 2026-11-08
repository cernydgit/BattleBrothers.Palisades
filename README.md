# Palisades (Battle Brothers mod)

Adds the active skill **Build Palisade** to every player character.

- Costs **4 AP** and **10 Fatigue** by default; both are adjustable in the mod settings (see below).
- Targets an adjacent empty tile (height difference at most 1).
- Raises a wooden palisade there. Nobody can pass it, friend or foe. It stays until the battle ends.
- The palisade is the vanilla bandit camp wall (`entity/tactical/objects/human_camp_wall`, `camp_18_*` sprites). The sprite follows the edge of the builder's hex, so palisades built all around a character form a hexagon.
- Built palisades also show up with the "highlight blocked tiles" toggle.

## Requirements

- Battle Brothers (vanilla, all DLCs optional)
- [Modern Hooks](https://www.nexusmods.com/battlebrothers/mods/685)
- [MSU](https://www.nexusmods.com/battlebrothers/mods/479) is optional. With MSU the costs can be changed in the mod settings; without it the defaults are used.

## Mod settings (MSU)

Open **Mod Settings → Palisade → General**:

| Setting | Range | Default |
| --- | --- | --- |
| Action Points | 1–10 | 4 |
| Fatigue | 1–50 | 10 |

The values are saved in your profile and apply to the skill right away, including existing savegames.

## Compatibility

- Overwrites no vanilla files. The only hook is on `player.onInit`, which adds the skill.
- The skill is not serialized, so the mod can be added to or removed from existing savegames.

## Installation

Zip the contents of this folder (the `scripts` and `gfx` directories at the zip root) as
`mod_palisade.zip` and put it into `Battle Brothers/data`.

```powershell
Compress-Archive -Path scripts, gfx -DestinationPath "..\..\..\data\mod_palisade.zip" -Force
```

## Files

| Path | Purpose |
| --- | --- |
| `scripts/!mods_preload/mod_palisade.nut` | Registers the mod with Modern Hooks, adds the MSU settings and adds the skill to player characters |
| `scripts/skills/actives/build_palisade_skill.nut` | The Build Palisade skill |
| `gfx/skills/mod_palisade_build.png`, `mod_palisade_build_sw.png` | Skill icon (normal and disabled) |
