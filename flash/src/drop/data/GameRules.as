package drop.data
{
	public class GameRules
	{
		private var gameState : GameState;

		public function GameRules(gameState : GameState)
		{
			this.gameState = gameState;
		}

		public function addPendingCredits(value : int) : void
		{
			gameState.pendingCredits += value;
			gameState.pendingCreditsUpdated.dispatch(gameState.pendingCredits);
		}

		public function addPendingCreditsToCredits() : void
		{
			gameState.credits += gameState.pendingCredits;
			gameState.creditsUpdated.dispatch(gameState.credits);

			gameState.pendingCredits = 0;
			gameState.pendingCreditsUpdated.dispatch(0);
		}
	}
}
