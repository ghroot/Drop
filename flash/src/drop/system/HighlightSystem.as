package drop.system
{
	import ash.core.Engine;
	import ash.core.NodeList;
	import ash.core.System;

	import drop.node.GameNode;
	import drop.node.MatchNode;

	import flash.geom.Point;

	public class HighlightSystem extends System
	{
		private var gameNode : GameNode;

		public function HighlightSystem()
		{
		}

		override public function addToEngine(engine : Engine) : void
		{
			gameNode = engine.getNodeList(GameNode).head;
			
			var matchNodeList : NodeList = engine.getNodeList(MatchNode);
			for (var matchNode : MatchNode = matchNodeList.head; matchNode; matchNode = matchNode.next)
			{
				if (shouldHighlightMatchNode(matchNode))
				{
					matchNode.stateComponent.stateMachine.changeState("highlighted");
				}
				else
				{
					matchNode.stateComponent.stateMachine.changeState("faded");
				}
			}
		}

		private function shouldHighlightMatchNode(matchNode : MatchNode) : Boolean
		{
			for each (var position : Point in gameNode.gameStateComponent.matchInfosToHighlight[0].positions)
			{
				if (matchNode.transformComponent.x == position.x &&
						matchNode.transformComponent.y == position.y)
				{
					return true;
				}
			}
			return false;
		}
	}
}
