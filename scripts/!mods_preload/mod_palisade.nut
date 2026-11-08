::ModPalisade <- {
	ID = "mod_palisade",
	Name = "Palisade",
	Version = "2.3.3",
	SkillID = "actives.build_palisade",
	// Sprite layer that shows a held Palisade on the bearer
	HeldSprite = "mod_palisade_held",
	SkillScript = "scripts/skills/actives/build_palisade_skill",
	ItemID = "shield.mod_palisade",
	// Shop entry path, relative to scripts/items/
	ItemShopScript = "shields/mod_palisade_shield",
	// Shop rarity: the lower, the more often the shop stocks it
	ShopRarity = {
		["building.marketplace"] = 50,
		["building.armorsmith"] = 30
	},
	// Used when MSU is not installed, and as the defaults of the mod settings
	Defaults = {
		ActionPointCost = 4,
		FatigueCost = 10,
		Price = 200,
		Weight = 50,
		Condition = 100,
		MeleeDefense = 25,
		RangedDefense = 50
	},
	MSUMod = null,
	// Palisade items used up in the current battle: { Item, BuilderID }
	UsedItems = []
};

// Current value from the MSU mod settings, or the default without MSU
::ModPalisade.getSetting <- function( _settingID )
{
	if (::ModPalisade.MSUMod != null && ::ModPalisade.MSUMod.ModSettings.hasSetting(_settingID))
	{
		return ::ModPalisade.MSUMod.ModSettings.getSetting(_settingID).getValue().tointeger();
	}

	return ::ModPalisade.Defaults[_settingID];
};

::ModPalisade.isHoldingPalisade <- function( _actor )
{
	local offhand = _actor.getItems().getItemAtSlot(::Const.ItemSlot.Offhand);
	return offhand != null && offhand.getID() == ::ModPalisade.ItemID;
};

::ModPalisade.keepUsedItem <- function( _item, _builder )
{
	// No campaign stash to return it to in scenario battles
	if (::Tactical.State.isScenarioMode())
	{
		return;
	}

	::ModPalisade.UsedItems.push({
		Item = _item,
		BuilderID = _builder.getID()
	});
};

// After the battle: into the stash, or into the builder's bag if the stash is full
::ModPalisade.returnUsedItems <- function()
{
	local used = ::ModPalisade.UsedItems;
	::ModPalisade.UsedItems = [];

	if (used.len() == 0 || !("Assets" in ::World) || ::World.Assets == null)
	{
		return;
	}

	local stash = ::World.Assets.getStash();

	foreach( entry in used )
	{
		if (stash.add(entry.Item) != null)
		{
			continue;
		}

		local returned = false;

		foreach( bro in ::World.getPlayerRoster().getAll() )
		{
			if (bro.getID() == entry.BuilderID)
			{
				returned = bro.getItems().addToBag(entry.Item);
				break;
			}
		}

		if (!returned)
		{
			::logWarning("mod_palisade: stash is full, a used Palisade could not be returned");
		}
	}
};

::ModPalisade.Mod <- ::Hooks.register(::ModPalisade.ID, ::ModPalisade.Version, ::ModPalisade.Name);
::ModPalisade.Mod.require("mod_modern_hooks");

// ">mod_msu" only sets load order; MSU is optional
::ModPalisade.Mod.queue(">mod_msu", function()
{
	if (::Hooks.hasMod("mod_msu"))
	{
		::ModPalisade.MSUMod = ::MSU.Class.Mod(::ModPalisade.ID, ::ModPalisade.Version, ::ModPalisade.Name);
		local d = ::ModPalisade.Defaults;

		local page = ::ModPalisade.MSUMod.ModSettings.addPage("General");
		page.addTitle("SkillTitle", "Build Palisade skill");
		page.addRangeSetting("ActionPointCost", d.ActionPointCost, 1, 10, 1, "Action Points", "How many Action Points the Build Palisade skill costs.");
		page.addRangeSetting("FatigueCost", d.FatigueCost, 1, 50, 1, "Fatigue", "How much Fatigue the Build Palisade skill builds up.");
		page.addTitle("ItemTitle", "Palisade item");
		page.addRangeSetting("Price", d.Price, 50, 500, 10, "Price", "Base value of the Palisade item. Shops adjust it like any other item.");
		page.addRangeSetting("Weight", d.Weight, 10, 100, 1, "Weight", "How much the Palisade lowers Maximum Fatigue while held.");
		page.addRangeSetting("Condition", d.Condition, 1, 200, 1, "Durability", "Maximum condition of the Palisade when used as a shield.");
		page.addRangeSetting("MeleeDefense", d.MeleeDefense, 10, 100, 1, "Melee Defense", "Melee Defense granted while the Palisade is held.");
		page.addRangeSetting("RangedDefense", d.RangedDefense, 10, 100, 1, "Ranged Defense", "Ranged Defense granted while the Palisade is held.");
	}

	// Marketplaces and armorers can stock the Palisade
	::ModPalisade.Mod.hook("scripts/entity/world/settlement", function( q )
	{
		q.onUpdateShopList = @(__original) function( _id, _list )
		{
			__original(_id, _list);

			if (_id in ::ModPalisade.ShopRarity)
			{
				_list.push({
					R = ::ModPalisade.ShopRarity[_id],
					P = 1.0,
					S = ::ModPalisade.ItemShopScript
				});
			}
		}
	});

	// A sprite layer on top of the others, used to draw a held Palisade
	::ModPalisade.Mod.hook("scripts/entity/tactical/player", function( q )
	{
		q.onInit = @(__original) function()
		{
			__original();

			if (!this.hasSprite(::ModPalisade.HeldSprite))
			{
				this.addSprite(::ModPalisade.HeldSprite).Visible = false;
			}
		}
	});

	// Tell the inventory screen that the item also takes up the main hand
	::ModPalisade.Mod.hook("scripts/ui/global/data_helper", function( q )
	{
		q.convertItemToUIData = @(__original) function( _item, _forceSmallIcon, _owner = null )
		{
			local result = __original(_item, _forceSmallIcon, _owner);

			if (result != null && _item.getBlockedSlotType() == ::Const.ItemSlot.Mainhand)
			{
				result.isBlockingMainhand <- true;
			}

			return result;
		}
	});

	// Draws the Palisade in the main hand slot too, see the file
	::Hooks.registerJS("ui/mods/mod_palisade/paperdoll.js");

	// Give back the Palisades used up in battle
	::ModPalisade.Mod.hook("scripts/states/world_state", function( q )
	{
		q.onCombatFinished = @(__original) function()
		{
			__original();
			::ModPalisade.returnUsedItems();
		}
	});

	// The Palisade is held with both hands: no punching while holding it
	::ModPalisade.Mod.hook("scripts/skills/actives/hand_to_hand", function( q )
	{
		q.isUsable = @(__original) function()
		{
			return __original() && !::ModPalisade.isHoldingPalisade(this.getContainer().getActor());
		}

		q.isHidden = @(__original) function()
		{
			return __original() || ::ModPalisade.isHoldingPalisade(this.getContainer().getActor());
		}
	});

	// Vanilla only knows two-handed items in the main hand. Teach the inventory
	// screen to clear both hands for an off hand item that blocks the main hand,
	// and to take that item off when something is put into the main hand.
	::ModPalisade.Mod.hook("scripts/ui/screens/character/character_screen", function( q )
	{
		q.helper_queryEquipmentTargetItems = @(__original) function( _inventory, _sourceItem )
		{
			local offhandSlot = ::Const.ItemSlot.Offhand;
			local mainhandSlot = ::Const.ItemSlot.Mainhand;
			local sourceSlotType = _sourceItem.getSlotType();
			local first = null;
			local second = null;

			if (sourceSlotType == offhandSlot && _sourceItem.getBlockedSlotType() == mainhandSlot)
			{
				first = _inventory.getItemAtSlot(offhandSlot);
				second = _inventory.getItemAtSlot(mainhandSlot);
			}
			else if (sourceSlotType == mainhandSlot && _inventory.hasBlockedSlot(mainhandSlot))
			{
				first = _inventory.getItemAtSlot(offhandSlot);
			}
			else
			{
				return __original(_inventory, _sourceItem);
			}

			if (first == null)
			{
				first = second;
				second = null;
			}

			return {
				firstItem = first,
				secondItem = second,
				slotsNeeded = (first != null ? 1 : 0) + (second != null ? 1 : 0)
			};
		}
	});
});
