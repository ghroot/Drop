package drop.system
{
	import ash.core.System;

	import drop.data.GameRules;

	public class AddPendingCreditsSystem extends System
	{
		private var gameRules : GameRules;

		public function AddPendingCreditsSystem(gameRules : GameRules)
		{
			this.gameRules = gameRules;
		}

		override public function update(time : Number) : void
		{
			gameRules.addPendingCreditsToCredits();
		}
	}
}
