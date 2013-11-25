package drop.system
{
	import ash.core.System;
	import ash.fsm.EngineStateMachine;

	import drop.data.GameState;

	public class MatchingStateEndingSystem extends System
	{
		private var stateMachine : EngineStateMachine;
		private var gameState : GameState;

		public function MatchingStateEndingSystem(stateMachine : EngineStateMachine, gameState : GameState)
		{
			this.stateMachine = stateMachine;
			this.gameState = gameState;
		}

		override public function update(time : Number) : void
		{
			if (gameState.atLeastOneMatch)
			{
				stateMachine.changeState("cascading");
			}
			else
			{
				stateMachine.changeState("selecting");
			}
		}
	}
}
