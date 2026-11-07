::ModPalisade <- {
	ID = "mod_palisade",
	Name = "Palisade",
	Version = "1.0.1",
	SkillID = "actives.build_palisade",
	SkillScript = "scripts/skills/actives/build_palisade_skill"
};

::ModPalisade.Mod <- ::Hooks.register(::ModPalisade.ID, ::ModPalisade.Version, ::ModPalisade.Name);
::ModPalisade.Mod.require("mod_modern_hooks");

// ">mod_msu" only sets load order; MSU is optional
::ModPalisade.Mod.queue(">mod_msu", function()
{
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
