package drop.system
{
	import ash.core.Engine;
	import ash.core.NodeList;
	import ash.core.System;
	import ash.fsm.EngineStateMachine;

	import drop.data.GameState;
	import drop.node.SelectNode;
	import drop.node.SelectNodeUtils;

	public class MatchingStateEndingSystem extends System
	{
		private var stateMachine : EngineStateMachine;
		private var gameState : GameState;

		private var selectNodeList : NodeList;

		public function MatchingStateEndingSystem(stateMachine : EngineStateMachine, gameState : GameState)
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
			if (gameState.atLeastOneMatch)
			{
				SelectNodeUtils.deselectSelectNodes(selectNodeList);
				stateMachine.changeState("cascading");
			}
			else if (gameState.isTryingSwap)
			{
				gameState.isTryingSwap = false;
				gameState.isSwappingBack = true;
				stateMachine.changeState("swapping");
			}
			else
			{
				stateMachine.changeState("selecting");
			}
		}
	}
}
