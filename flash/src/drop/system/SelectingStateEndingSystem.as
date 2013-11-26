package drop.system
{
	import ash.core.Engine;
	import ash.core.System;
	import ash.fsm.EngineStateMachine;

	import drop.data.GameState;

	public class SelectingStateEndingSystem extends System
	{
		private var stateMachine : EngineStateMachine;
		private var gameState : GameState;

		public function SelectingStateEndingSystem(stateMachine : EngineStateMachine, gameState : GameState)
		{
			this.stateMachine = stateMachine;
			this.gameState = gameState;
		}

		override public function addToEngine(engine : Engine) : void
		{
			gameState.shouldStartSwap = false;
		}

		override public function update(time : Number) : void
		{
			if (gameState.shouldStartSwap)
			{
				gameState.isTryingSwap = true;
				stateMachine.changeState("swapping");
			}
		}
	}
}