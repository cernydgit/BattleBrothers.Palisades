// Vanilla draws a two-handed main hand item faded in the off hand slot too.
// The Palisade is the other way round: an off hand item that also takes up
// the main hand. Draw it faded in the main hand slot the same way.
(function ()
{
	var assignEquipment = CharacterScreenPaperdollModule.prototype.assignEquipment;

	CharacterScreenPaperdollModule.prototype.assignEquipment = function (_brotherId, _data)
	{
		assignEquipment.call(this, _brotherId, _data);

		var mainhandKey = CharacterScreenIdentifier.ItemSlot.Mainhand;
		var offhandKey = CharacterScreenIdentifier.ItemSlot.Offhand;

		if (_data === null || typeof _data !== 'object' || (mainhandKey in _data) || !(offhandKey in _data))
		{
			return;
		}

		var offhand = _data[offhandKey];

		if (offhand !== null && offhand.isBlockingMainhand === true)
		{
			var slot = this.mLeftEquipmentSlots.RightHand;
			this.assignItemToSlot(slot, _brotherId, offhand, true);

			// Keep it a main hand slot, so a weapon can still be dropped onto it
			// (the game then takes the Palisade off)
			var itemData = slot.Container.data('item');
			if (itemData)
			{
				itemData.slotType = CharacterScreenIdentifier.ItemSlot.Mainhand;
				slot.Container.data('item', itemData);
			}
		}
	};
})();
