# Palisades (Battle Brothers mod)

Adds the **Palisade** item: a bundle of sharpened stakes that is carried with both hands like a large shield and can be driven into the ground as an impassable palisade.

## The Palisade item

- Sold by **marketplaces** and **armorers**. Base price 200 crowns by default.
- Goes into the off hand slot and also takes up the main hand slot (two-handed). It can be put into a bag.
- While held it works as a shield: **+25 Melee Defense** and **+50 Ranged Defense** by default, with 100 durability. It lowers Maximum Fatigue by 50 by default.
- Holding it with both hands means no attacks, not even with bare fists.
- The inventory screen clears both hands when you equip it, and takes it off when you put a weapon into the main hand.

## The Build Palisade skill

- Available only while the character holds a Palisade in both hands. It is not available from the bag.
- Costs **4 AP** and **10 Fatigue** by default.
- Targets an adjacent empty tile (height difference at most 1).
- Raises a wooden palisade there. Nobody can pass it, friend or foe. It stays until the battle ends.
- The Palisade item is used up. After the battle it goes back to the company stash. If the stash is full, it goes into the builder's bag if there is room.
- The palisade is the vanilla bandit camp wall (`entity/tactical/objects/human_camp_wall`, `camp_18_*` sprites). The sprite follows the edge of the builder's hex, so palisades built all around a character form a hexagon.
- Built palisades also show up with the "highlight blocked tiles" toggle.

## Requirements

- Battle Brothers (vanilla, all DLCs optional)
- [Modern Hooks](https://www.nexusmods.com/battlebrothers/mods/685)
- [MSU](https://www.nexusmods.com/battlebrothers/mods/479) is optional. With MSU the values below can be changed in the mod settings; without it the defaults are used.

## Mod settings (MSU)

Open **Mod Settings → Palisade → General**:

| Setting | Range | Default |
| --- | --- | --- |
| Action Points (skill) | 1–10 | 4 |
| Fatigue (skill) | 1–50 | 10 |
| Price (item) | 50–500 | 200 |
| Weight (item, Maximum Fatigue penalty) | 10–100 | 50 |
| Durability (item) | 1–200 | 100 |
| Melee Defense (item) | 10–100 | 25 |
| Ranged Defense (item) | 10–100 | 50 |

The values are saved in your profile and apply right away, including Palisades you already own.

## Compatibility

- Overwrites no vanilla files. Hooks:
  - `settlement.onUpdateShopList` adds the item to marketplace and armorer stock.
  - `world_state.onCombatFinished` gives back the Palisades used in battle.
  - `hand_to_hand.isUsable` / `isHidden` disable fists while a Palisade is held.
  - `character_screen.helper_queryEquipmentTargetItems` handles an off hand item that blocks the main hand.
- The skill is not serialized. Palisade items are saved like any other shield, so removing the mod breaks savegames that contain them.

## Installation

Zip the contents of this folder (the `scripts` and `gfx` directories at the zip root) as
`mod_palisade.zip` and put it into `Battle Brothers/data`.

```powershell
Compress-Archive -Path scripts, gfx -DestinationPath "..\..\..\data\mod_palisade.zip" -Force
```

## Files

| Path | Purpose |
| --- | --- |
| `scripts/!mods_preload/mod_palisade.nut` | Registers the mod with Modern Hooks, adds the MSU settings and the hooks |
| `scripts/items/shields/mod_palisade_shield.nut` | The Palisade item |
| `scripts/skills/actives/build_palisade_skill.nut` | The Build Palisade skill |
| `gfx/skills/mod_palisade_build.png`, `mod_palisade_build_sw.png` | Skill icon (normal and disabled) |
| `gfx/ui/items/shields/mod_palisade_icon.png`, `mod_palisade_inventory.png` | Item icons (slot and tooltip) |
