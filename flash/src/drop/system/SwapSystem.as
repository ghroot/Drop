package drop.system
{
	import ash.core.Engine;
	import ash.core.NodeList;
	import ash.core.System;

	import drop.data.GameState;
	import drop.node.SelectNode;

	import starling.animation.Tween;

	public class SwapSystem extends System
	{
		private var gameState : GameState;

		private var tween1 : Tween;
		private var tween2 : Tween;

		public function SwapSystem(gameState : GameState)
		{
			this.gameState = gameState;
		}

		override public function addToEngine(engine : Engine) : void
		{
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

						tween2 = new Tween(selectedSelectNode.transformComponent, 0.2);
						tween2.animate("x", selectNode.transformComponent.x);
						tween2.animate("y", selectNode.transformComponent.y);

						gameState.swapInProgress = true;

						break;
					}
				}
			}
		}

		override public function update(time : Number) : void
		{
			tween1.advanceTime(time);
			tween2.advanceTime(time);

			if (gameState.swapInProgress &&
					tween1.isComplete &&
					tween2.isComplete)
			{
				gameState.swapInProgress = false;
			}
		}
	}
}
