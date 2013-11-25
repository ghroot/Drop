package drop.system
{
	import ash.core.Engine;
	import ash.core.NodeList;
	import ash.core.System;

	import drop.board.Matcher;
	import drop.node.MatchNode;
	import drop.node.SelectNode;

	public class SwapSystem extends System
	{
		private var matcher : Matcher;

		private var selectNodeList : NodeList;
		private var matchNodeList : NodeList;
		private var matchNodes : Vector.<MatchNode>;

		public function SwapSystem(matcher : Matcher)
		{
			this.matcher = matcher;

			matchNodes = new Vector.<MatchNode>();
		}

		override public function addToEngine(engine : Engine) : void
		{
			selectNodeList = engine.getNodeList(SelectNode);
			matchNodeList = engine.getNodeList(MatchNode);
		}

		override public function update(time : Number) : void
		{
			var selectedSelectNode : SelectNode = null;
			for (var selectNode : SelectNode = selectNodeList.head; selectNode; selectNode = selectNode.next)
			{
				if (selectNode.selectComponent.isSelected)
				{
					if (selectedSelectNode == null)
					{
						selectedSelectNode = selectNode;
					}
					else
					{
						swap(selectedSelectNode, selectNode);

						if (hasNoMatches())
						{
							swap(selectedSelectNode, selectNode);
						}

						break;
					}
				}
			}
		}

		private function swap(selectNode1 : SelectNode, selectNode2 : SelectNode) : void
		{
			var tempPositionX : Number = selectNode1.transformComponent.x;
			var tempPositionY : Number = selectNode1.transformComponent.y;
			selectNode1.transformComponent.x = selectNode2.transformComponent.x;
			selectNode1.transformComponent.y = selectNode2.transformComponent.y;
			selectNode2.transformComponent.x = tempPositionX;
			selectNode2.transformComponent.y = tempPositionY;
		}

		private function hasNoMatches() : Boolean
		{
			matchNodes.length = 0;
			for (var matchNode : MatchNode = matchNodeList.head; matchNode; matchNode = matchNode.next)
			{
				matchNodes[matchNodes.length] = matchNode;
			}
			return !matcher.hasMatches(matchNodes);
		}
	}
}
