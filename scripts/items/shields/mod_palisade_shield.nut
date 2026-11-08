// A bundle of sharpened stakes, carried with both hands like a large shield.
// While held it grants the Build Palisade skill.
this.mod_palisade_shield <- this.inherit("scripts/items/shields/shield", {
	m = {},
	function create()
	{
		this.shield.create();
		this.m.ID = ::ModPalisade.ItemID;
		this.m.Name = "Palisade";
		this.m.Description = "A bundle of sharpened wooden stakes, lashed together and carried with both hands. Held up, it covers its bearer like a large shield. Driven into the ground, it raises a palisade that nobody can pass.";
		this.m.AddGenericSkill = true;
		// No character sprite exists for this item, so it is not drawn on the bearer
		this.m.ShowOnCharacter = false;
		this.m.ShieldDecal = "";
		this.m.Icon = "shields/mod_palisade_icon.png";
		this.m.IconLarge = "shields/mod_palisade_inventory.png";
		this.m.SoundOnHit = this.Const.Sound.ShieldHitWood;
		// Held with both hands: it also takes up the main hand slot
		this.m.BlockedSlotType = this.Const.ItemSlot.Mainhand;
		this.m.IsAllowedInBag = true;
		this.applySettings();
		this.m.Condition = this.m.ConditionMax;
	}

	// Values come from the mod settings (MSU), so changes apply to existing items too
	function applySettings()
	{
		this.m.Value = ::ModPalisade.getSetting("Price");
		this.m.StaminaModifier = -1 * ::ModPalisade.getSetting("Weight");
		this.m.MeleeDefense = ::ModPalisade.getSetting("MeleeDefense");
		this.m.RangedDefense = ::ModPalisade.getSetting("RangedDefense");

		local conditionMax = ::ModPalisade.getSetting("Condition");

		if (this.m.ConditionMax != conditionMax)
		{
			local wasIntact = this.m.ConditionMax == 0 || this.m.Condition >= this.m.ConditionMax;
			this.m.ConditionMax = conditionMax;
			this.m.Condition = wasIntact ? conditionMax * 1.0 : this.Math.minf(this.m.Condition, conditionMax);
		}
	}

	function getTooltip()
	{
		this.applySettings();
		local result = this.shield.getTooltip();
		result.push({
			id = 20,
			type = "text",
			icon = "ui/icons/special.png",
			text = "Two-handed: also takes up the main hand slot"
		});
		result.push({
			id = 21,
			type = "text",
			icon = "ui/icons/special.png",
			text = "While held, grants [color=" + this.Const.UI.Color.PositiveValue + "]Build Palisade[/color]. The palisade is used up when built and returns to the stash after the battle"
		});
		return result;
	}

	function getValue()
	{
		this.applySettings();
		return this.shield.getValue();
	}

	function onEquip()
	{
		this.applySettings();
		this.shield.onEquip();
		this.addSkill(::new(::ModPalisade.SkillScript));
	}

	function onUpdateProperties( _properties )
	{
		this.applySettings();
		this.shield.onUpdateProperties(_properties);
	}

	function onDeserialize( _in )
	{
		this.shield.onDeserialize(_in);
		this.applySettings();
	}

});
