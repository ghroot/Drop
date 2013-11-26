package drop.system
{
	import ash.core.Engine;
	import ash.core.NodeList;
	import ash.core.System;
	import ash.fsm.EngineStateMachine;

	import drop.data.GameState;
	import drop.node.SelectNode;
	import drop.node.SelectNodeUtils;

	public class SwappingStateEndingSystem extends System
	{
		private var stateMachine : EngineStateMachine;
		private var gameState : GameState;

		private var selectNodeList : NodeList;

		public function SwappingStateEndingSystem(stateMachine : EngineStateMachine, gameState : GameState)
		{
			this.stateMachine = stateMachine;
			this.gameState = gameState;
		}

		override public function addToEngine(engine : Engine) : void
		{
			selectNodeList = engine.getNodeList(SelectNode);
		}

		override public function update(time : Number) : void
		{
			if (!gameState.swapInProgress)
			{
				if (gameState.isSwappingBack)
				{
					SelectNodeUtils.deselectSelectNodes(selectNodeList);
					gameState.isSwappingBack = false;
					stateMachine.changeState("selecting");
				}
				else
				{
					stateMachine.changeState("matching");
				}
			}
		}
	}
}
