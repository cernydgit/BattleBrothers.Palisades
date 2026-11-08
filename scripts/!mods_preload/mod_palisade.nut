::ModPalisade <- {
	ID = "mod_palisade",
	Name = "Palisade",
	Version = "1.1.1",
	SkillID = "actives.build_palisade",
	SkillScript = "scripts/skills/actives/build_palisade_skill",
	// Used when MSU is not installed, and as the defaults of the mod settings
	Defaults = {
		ActionPointCost = 4,
		FatigueCost = 10
	},
	MSUMod = null
};

// Current cost from the MSU mod settings, or the default without MSU
::ModPalisade.getCost <- function( _settingID )
{
	if (::ModPalisade.MSUMod != null && ::ModPalisade.MSUMod.ModSettings.hasSetting(_settingID))
	{
		return ::ModPalisade.MSUMod.ModSettings.getSetting(_settingID).getValue().tointeger();
	}

	return ::ModPalisade.Defaults[_settingID];
};

::ModPalisade.Mod <- ::Hooks.register(::ModPalisade.ID, ::ModPalisade.Version, ::ModPalisade.Name);
::ModPalisade.Mod.require("mod_modern_hooks");

// ">mod_msu" only sets load order; MSU is optional
::ModPalisade.Mod.queue(">mod_msu", function()
{
	if (::Hooks.hasMod("mod_msu"))
	{
		::ModPalisade.MSUMod = ::MSU.Class.Mod(::ModPalisade.ID, ::ModPalisade.Version, ::ModPalisade.Name);

		local page = ::ModPalisade.MSUMod.ModSettings.addPage("General");
		page.addRangeSetting("ActionPointCost", ::ModPalisade.Defaults.ActionPointCost, 1, 10, 1, "Action Points", "How many Action Points the Build Palisade skill costs.");
		page.addRangeSetting("FatigueCost", ::ModPalisade.Defaults.FatigueCost, 1, 50, 1, "Fatigue", "How much Fatigue the Build Palisade skill builds up.");
	}

	// Every player character gets the skill. It is not serialized,
	// so it is re-added on every load and never ends up in savegames.
	::ModPalisade.Mod.hook("scripts/entity/tactical/player", function( q )
	{
		q.onInit = @(__original) function()
		{
			__original();

			if (!this.getSkills().hasSkill(::ModPalisade.SkillID))
			{
				this.getSkills().add(::new(::ModPalisade.SkillScript));
			}
		}
	});
});
