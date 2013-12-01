package drop.system
{
	import ash.core.System;

	import drop.data.GameRules;
	import drop.data.GameState;

	public class ComboSystem extends System
	{
		private var gameState : GameState;
		private var gameRules : GameRules;

		public function ComboSystem(gameState : GameState, gameRules : GameRules)
		{
			this.gameState = gameState;
			this.gameRules = gameRules;
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
				gameRules.addPendingCredits(5000);
			}
			else if (gameState.totalNumberOfMatchesDuringCascading >= 20)
			{
				gameRules.addPendingCredits(1000);
			}
			else if (gameState.totalNumberOfLineBlastsDuringCascading >= 10)
			{
				gameRules.addPendingCredits(200);
			}

			gameState.totalNumberOfMatchesDuringCascading = 0;
		}

		private function applyLineBlastComboBonus() : void
		{
			if (gameState.totalNumberOfLineBlastsDuringCascading >= 10)
			{
				gameRules.addPendingCredits(1000);
			}
			else if (gameState.totalNumberOfLineBlastsDuringCascading >= 5)
			{
				gameRules.addPendingCredits(300);
			}
			else if (gameState.totalNumberOfLineBlastsDuringCascading >= 3)
			{
				gameRules.addPendingCredits(50);
			}

			gameState.totalNumberOfLineBlastsDuringCascading = 0;
		}
	}
}
