package drop.system
{
	import ash.core.Engine;
	import ash.core.System;
	import ash.fsm.EngineStateMachine;

	import drop.data.GameState;

	public class SelectingStateEndingSystem extends System
	{
		private var engineStateMachine : EngineStateMachine;
		private var gameState : GameState;

		public function SelectingStateEndingSystem(engineStateMachine : EngineStateMachine, gameState : GameState)
		{
			this.engineStateMachine = engineStateMachine;
			this.gameState = gameState;
		}

		override public function addToEngine(engine : Engine) : void
		{
			gameState.shouldSubmit = false;
		}

		override public function update(time : Number) : void
		{
			if (gameState.shouldSubmit)
			{
				engineStateMachine.changeState("submitting");
			}
		}
	}
}