package drop.system
{
	import ash.core.Engine;
	import ash.core.NodeList;
	import ash.core.System;
	import ash.fsm.EngineStateMachine;

	import drop.node.GameNode;
	import drop.node.SelectNode;
	import drop.node.SelectNodeUtils;

	public class SwappingStateEndingSystem extends System
	{
		private var stateMachine : EngineStateMachine;

		private var gameNode : GameNode;
		private var selectNodeList : NodeList;

		public function SwappingStateEndingSystem(stateMachine : EngineStateMachine)
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
			if (!gameNode.gameStateComponent.swapInProgress)
			{
				if (gameNode.gameStateComponent.isSwappingBack)
				{
					SelectNodeUtils.deselectSelectNodes(selectNodeList);
					gameNode.gameStateComponent.isSwappingBack = false;
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
