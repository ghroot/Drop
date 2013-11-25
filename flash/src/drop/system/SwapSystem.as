package drop.system
{
	import ash.core.Engine;
	import ash.core.NodeList;
	import ash.core.System;

	import drop.node.SelectNode;

	public class SwapSystem extends System
	{
		private var selectNodeList : NodeList;

		public function SwapSystem()
		{
		}

		override public function addToEngine(engine : Engine) : void
		{
			selectNodeList = engine.getNodeList(SelectNode);
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
						var tempPositionX : Number = selectedSelectNode.transformComponent.x;
						var tempPositionY : Number = selectedSelectNode.transformComponent.y;
						selectedSelectNode.transformComponent.x = selectNode.transformComponent.x;
						selectedSelectNode.transformComponent.y = selectNode.transformComponent.y;
						selectNode.transformComponent.x = tempPositionX;
						selectNode.transformComponent.y = tempPositionY;

						break;
					}
				}
			}
		}
	}
}
