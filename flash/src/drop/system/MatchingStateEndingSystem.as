package drop.system
{
	import ash.core.Engine;
	import ash.core.NodeList;
	import ash.core.System;
	import ash.fsm.EngineStateMachine;

	import drop.node.GameNode;
	import drop.node.SelectNode;
	import drop.node.SelectNodeUtils;

	public class MatchingStateEndingSystem extends System
	{
		private var stateMachine : EngineStateMachine;

		private var gameNode : GameNode;
		private var selectNodeList : NodeList;

		public function MatchingStateEndingSystem(stateMachine : EngineStateMachine)
		{
			this.stateMachine = stateMachine;
		}

		override public function addToEngine(engine : Engine) : void
		{
			gameNode = engine.getNodeList(GameNode).head;
			selectNodeList = engine.getNodeList(SelectNode);
		}

		override public function update(time : Number) : void
		{
			if (gameNode.gameStateComponent.matchInfos.length > 0)
			{
				SelectNodeUtils.deselectSelectNodes(selectNodeList);
				gameNode.gameStateComponent.isTryingSwap = false;

				if (gameNode.gameStateComponent.matchInfosToHighlight.length > 0)
				{
					stateMachine.changeState("highlighting");
				}
				else
				{
					stateMachine.changeState("cascading");
				}
			}
			else if (gameNode.gameStateComponent.isTryingSwap)
			{
				gameNode.gameStateComponent.isTryingSwap = false;
				gameNode.gameStateComponent.isSwappingBack = true;
				stateMachine.changeState("swapping");
			}
			else
			{
				stateMachine.changeState("turnEnd");
			}
		}
	}
}
