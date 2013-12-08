package drop.system
{
	import ash.core.*;

	import drop.data.Input;
	import drop.node.GameNode;
	import drop.node.SelectNode;

	import flash.geom.Rectangle;

	public class SelectControlSystem extends AbstractControlSystem
	{
		private var tileSize : int;

		private var gameNode : GameNode;
		private var selectNodeList : NodeList;
		private var reusableRectangle : Rectangle;

		public function SelectControlSystem(tileSize : int)
		{
			super(Vector.<int>([Input.TOUCH_BEGAN, Input.TOUCH_MOVE]));

			this.tileSize = tileSize;

			reusableRectangle = new Rectangle(0, 0, tileSize, tileSize);
		}

		override public function addToEngine(engine : Engine) : void
		{
			super.addToEngine(engine);

			gameNode = engine.getNodeList(GameNode).head;
			selectNodeList = engine.getNodeList(SelectNode);

			gameNode.gameStateComponent.isSelecting = true;
			gameNode.gameStateComponent.shouldStartSwap = false;
		}

		override public function removeFromEngine(engine : Engine) : void
		{
			gameNode.gameStateComponent.isSelecting = false;
		}

		override protected function handleInput(input : Input) : void
		{
			var selectNode : SelectNode = getSelectNodeForInput(input);
			if (selectNode != null)
			{
				if (input.type == Input.TOUCH_BEGAN)
				{
					handleInputBegan(selectNode);
				}
				else if (input.type == Input.TOUCH_MOVE)
				{
					handleInputMove(selectNode);
				}
			}
		}

		private function handleInputBegan(selectNode : SelectNode) : void
		{
			var selectedSelectNode : SelectNode = getSelectedNode();
			if (selectedSelectNode == null)
			{
				selectNode.selectComponent.isSelected = true;
				selectNode.stateComponent.stateMachine.changeState("selected");
			}
			else if (selectedSelectNode.entity == selectNode.entity)
			{
				selectedSelectNode.selectComponent.isSelected = false;
				selectedSelectNode.stateComponent.stateMachine.changeState("idle");
			}
			else
			{
				if (Math.abs(selectedSelectNode.transformComponent.x - selectNode.transformComponent.x) +
						Math.abs(selectedSelectNode.transformComponent.y - selectNode.transformComponent.y) == tileSize)
				{
					selectNode.selectComponent.isSelected = true;
					selectNode.stateComponent.stateMachine.changeState("selected");

					gameNode.gameStateComponent.shouldStartSwap = true;
				}
				else
				{
					selectedSelectNode.selectComponent.isSelected = false;
					selectedSelectNode.stateComponent.stateMachine.changeState("idle");

					selectNode.selectComponent.isSelected = true;
					selectNode.stateComponent.stateMachine.changeState("selected");
				}
			}
		}

		private function handleInputMove(selectNode : SelectNode) : void
		{
			var selectedSelectNode : SelectNode = getSelectedNode();
			if (selectedSelectNode != null &&
					Math.abs(selectedSelectNode.transformComponent.x - selectNode.transformComponent.x) +
					Math.abs(selectedSelectNode.transformComponent.y - selectNode.transformComponent.y) == tileSize)
			{
				selectNode.selectComponent.isSelected = true;
				selectNode.stateComponent.stateMachine.changeState("selected");

				gameNode.gameStateComponent.shouldStartSwap = true;
			}
		}

		private function getSelectedNode() : SelectNode
		{
			for (var selectNode : SelectNode = selectNodeList.head; selectNode; selectNode = selectNode.next)
			{
				if (selectNode.selectComponent.isSelected)
				{
					return selectNode;
				}
			}
			return null;
		}

		private function getSelectNodeForInput(input : Input) : SelectNode
		{
			for (var selectNode : SelectNode = selectNodeList.head; selectNode; selectNode = selectNode.next)
			{
				reusableRectangle.x = selectNode.transformComponent.x;
				reusableRectangle.y = selectNode.transformComponent.y;
				if (reusableRectangle.containsPoint(input.position))
				{
					return selectNode;
				}
			}
			return null;
		}
	}
}