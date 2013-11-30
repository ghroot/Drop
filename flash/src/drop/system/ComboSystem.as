package drop.system
{
	import ash.core.System;

	import drop.data.GameState;

	public class ComboSystem extends System
	{
		private var gameState : GameState;

		public function ComboSystem(gameState : GameState)
		{
			this.gameState = gameState;
		}

		override public function update(time : Number) : void
		{
			applyMatchesComboBonus();
			applyLineBlastComboBonus();
		}

		private function applyMatchesComboBonus() : void
		{
			if (gameState.totalNumberOfMatchesDuringCascading >= 50)
			{
				gameState.addPendingCredits(5000);
			}
			else if (gameState.totalNumberOfMatchesDuringCascading >= 20)
			{
				gameState.addPendingCredits(1000);
			}
			else if (gameState.totalNumberOfLineBlastsDuringCascading >= 10)
			{
				gameState.addPendingCredits(200);
			}

			gameState.totalNumberOfMatchesDuringCascading = 0;
		}

		private function applyLineBlastComboBonus() : void
		{
			if (gameState.totalNumberOfLineBlastsDuringCascading >= 10)
			{
				gameState.addPendingCredits(1000);
			}
			else if (gameState.totalNumberOfLineBlastsDuringCascading >= 5)
			{
				gameState.addPendingCredits(300);
			}
			else if (gameState.totalNumberOfLineBlastsDuringCascading >= 3)
			{
				gameState.addPendingCredits(50);
			}

			gameState.totalNumberOfLineBlastsDuringCascading = 0;
		}
	}
}
