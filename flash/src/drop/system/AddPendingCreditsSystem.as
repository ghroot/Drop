package drop.system
{
	import ash.core.System;

	import drop.data.GameState;

	public class AddPendingCreditsSystem extends System
	{
		private var gameState : GameState;

		public function AddPendingCreditsSystem(gameState : GameState)
		{
			this.gameState = gameState;
		}

		override public function update(time : Number) : void
		{
			gameState.addPendingCreditsToCredits();
		}
	}
}
