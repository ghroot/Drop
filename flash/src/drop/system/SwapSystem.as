package drop.system
{
	import ash.core.Engine;
	import ash.core.NodeList;
	import ash.core.System;

	import drop.node.GameNode;
	import drop.node.SelectNode;

	import starling.animation.Tween;
	import starling.core.Starling;

	public class SwapSystem extends System
	{
		private var gameNode : GameNode;
		private var tween1 : Tween;
		private var tween2 : Tween;

		public function SwapSystem()
		{
		}

		override public function addToEngine(engine : Engine) : void
		{
			gameNode = engine.getNodeList(GameNode).head;

			var selectNodeList : NodeList = engine.getNodeList(SelectNode);

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
						tween1 = new Tween(selectNode.transformComponent, 0.2);
						tween1.animate("x", selectedSelectNode.transformComponent.x);
						tween1.animate("y", selectedSelectNode.transformComponent.y);
						Starling.juggler.add(tween1);

						tween2 = new Tween(selectedSelectNode.transformComponent, 0.2);
						tween2.animate("x", selectNode.transformComponent.x);
						tween2.animate("y", selectNode.transformComponent.y);
						Starling.juggler.add(tween2);

						gameNode.gameStateComponent.swapInProgress = true;

						break;
					}
				}
			}
		}

		override public function update(time : Number) : void
		{
			if (gameNode.gameStateComponent.swapInProgress &&
					tween1.isComplete &&
					tween2.isComplete)
			{
				gameNode.gameStateComponent.swapInProgress = false;
			}
		}
	}
}
