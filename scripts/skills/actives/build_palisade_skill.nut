this.build_palisade_skill <- this.inherit("scripts/skills/skill", {
	m = {
		// Vanilla bandit camp palisade object (Battle Brothers' human_camp_wall)
		ObjectScript = "entity/tactical/objects/human_camp_wall",
		// Brushes from the vanilla bandit camp palisade, picked so the wall
		// runs across the direction the builder is facing.
		BrushesByDirection = [
			[ "camp_18_03" ],               // N
			[ "camp_18_01", "camp_18_04" ], // NE
			[ "camp_18_02", "camp_18_08" ], // SE
			[ "camp_18_05" ],               // S
			[ "camp_18_01", "camp_18_04" ], // SW
			[ "camp_18_02", "camp_18_08" ]  // NW
		]
	},
	function create()
	{
		this.m.ID = "actives.build_palisade";
		this.m.Name = "Build Palisade";
		this.m.Description = "Quickly drive sharpened stakes into the ground to raise a wooden palisade on an adjacent empty tile. The palisade cannot be passed by anyone, friend or foe, and lasts until the end of the battle.";
		this.m.Icon = "skills/mod_palisade_build.png";
		this.m.IconDisabled = "skills/mod_palisade_build_sw.png";
		this.m.Overlay = "";
		this.m.SoundOnUse = [
			"sounds/combat/hammer_strike_hit_01.wav",
			"sounds/combat/hammer_strike_hit_02.wav",
			"sounds/combat/hammer_strike_hit_03.wav"
		];
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.Any;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = true;
		this.m.IsTargetingActor = false;
		this.m.IsVisibleTileNeeded = false;
		this.m.IsStacking = false;
		this.m.IsAttack = false;
		this.m.IsIgnoredAsAOO = true;
		this.m.IsUsingHitchance = false;
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 10;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.MaxLevelDifference = 1;
	}

	function getTooltip()
	{
		local ret = [
			{
				id = 1,
				type = "title",
				text = this.getName()
			},
			{
				id = 2,
				type = "description",
				text = this.getDescription()
			},
			{
				id = 3,
				type = "text",
				text = this.getCostString()
			},
			{
				id = 4,
				type = "text",
				icon = "ui/icons/special.png",
				text = "Creates an [color=" + this.Const.UI.Color.PositiveValue + "]impassable[/color] palisade on an adjacent empty tile"
			}
		];

		if (this.Tactical.isActive() && !this.hasEmptyAdjacentTile())
		{
			ret.push({
				id = 9,
				type = "text",
				icon = "ui/tooltips/warning.png",
				text = "[color=" + this.Const.UI.Color.NegativeValue + "]Requires an adjacent empty tile[/color]"
			});
		}

		return ret;
	}

	function getCursorForTile( _tile )
	{
		return this.Const.UI.Cursor.Hand;
	}

	function hasEmptyAdjacentTile()
	{
		local actor = this.getContainer().getActor();

		if (!actor.isPlacedOnMap())
		{
			return false;
		}

		local myTile = actor.getTile();

		for( local i = 0; i < 6; i = ++i )
		{
			if (myTile.hasNextTile(i) && this.isValidTile(myTile, myTile.getNextTile(i)))
			{
				return true;
			}
		}

		return false;
	}

	function isValidTile( _originTile, _targetTile )
	{
		return _targetTile.IsEmpty && this.Math.abs(_targetTile.Level - _originTile.Level) <= this.m.MaxLevelDifference;
	}

	function isUsable()
	{
		return this.skill.isUsable() && this.hasEmptyAdjacentTile();
	}

	function onVerifyTarget( _originTile, _targetTile )
	{
		if (!this.skill.onVerifyTarget(_originTile, _targetTile))
		{
			return false;
		}

		return this.isValidTile(_originTile, _targetTile);
	}

	// The engine builds the "highlight blocked tiles" marks only once, when the
	// battle map is created, so rebuild them to include the new palisade.
	function refreshBlockedTileHighlights()
	{
		this.Tactical.clearBlockedTileHighlights();
		this.Tactical.createBlockedTileHighlights();
		this.Tactical.setBlockedTileHighlightsVisibility(this.Settings.getTempGameplaySettings().HighlightBlockedTiles);
	}

	function onUse( _user, _targetTile )
	{
		local myTile = _user.getTile();
		local dir = myTile.getDirectionTo(_targetTile);
		local wall = _targetTile.spawnObject(this.m.ObjectScript);

		if (wall == null)
		{
			return false;
		}

		if (dir >= 0 && dir < this.m.BrushesByDirection.len())
		{
			local brushes = this.m.BrushesByDirection[dir];
			wall.getSprite("body").setBrush(brushes[this.Math.rand(0, brushes.len() - 1)]);
		}

		this.refreshBlockedTileHighlights();

		if (_targetTile.IsVisibleForPlayer)
		{
			this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(_user) + " builds a palisade");
		}

		return true;
	}

});
