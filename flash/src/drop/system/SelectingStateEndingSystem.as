package drop.system
{
	import ash.core.Engine;
	import ash.core.System;
	import ash.fsm.EngineStateMachine;

	import drop.node.GameNode;

	public class SelectingStateEndingSystem extends System
	{
		private var stateMachine : EngineStateMachine;

		private var gameNode : GameNode;

		public function SelectingStateEndingSystem(stateMachine : EngineStateMachine)
		{
			this.stateMachine = stateMachine;
		}

		override public function addToEngine(engine : Engine) : void
		{
			gameNode = engine.getNodeList(GameNode).head;
		}

		override public function update(time : Number) : void
		{
			if (gameNode.gameStateComponent.shouldStartSwap)
			{
				gameNode.gameStateComponent.isTryingSwap = true;
				stateMachine.changeState("swapping");
			}
		}
	}
}