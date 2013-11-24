package drop.system
{
	import ash.core.*;

	import drop.data.GameState;
	import drop.data.Input;
	import drop.node.SelectNode;

	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class SelectControlSystem extends AbstractControlSystem
	{
		private var boardSize : Point;
		private var tileSize : int;

		private var selectNodeList : NodeList;
		private var reusableRectangle : Rectangle;

		public function SelectControlSystem(gameState : GameState, boardSize : Point, tileSize : int)
		{
			super(gameState, Vector.<int>([Input.TOUCH_BEGAN, Input.TOUCH_MOVE, Input.TOUCH_ENDED]));

			this.boardSize = boardSize;
			this.tileSize = tileSize;

			reusableRectangle = new Rectangle(0, 0, tileSize, tileSize);
		}

		override public function addToEngine(engine : Engine) : void
		{
			selectNodeList = engine.getNodeList(SelectNode);
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
				else if (input.type == Input.TOUCH_ENDED)
				{
					handleInputEnded(selectNode);
				}
			}
		}

		private function handleInputBegan(selectNode : SelectNode) : void
		{
			selectSelectNode(selectNode);
		}

		private function handleInputMove(selectNode : SelectNode) : void
		{
			selectSelectNode(selectNode);
		}

		private function handleInputEnded(selectNode : SelectNode) : void
		{
			gameState.shouldSubmitCurrentSelection = true;
		}

		private function getSelectNodeForInput(input : Input) : SelectNode
		{
			for (var selectNode : SelectNode = selectNodeList.head; selectNode; selectNode = selectNode.next)
			{
				reusableRectangle.x = selectNode.transformComponent.x;
				reusableRectangle.y = selectNode.transformComponent.y;
				if (reusableRectangle.containsPoint(input.location))
				{
					return selectNode;
				}
			}
			return null;
		}

		private function getLastSelectedSelectNode() : SelectNode
		{
			var lastSelectedSelectNode : SelectNode = null;
			for (var selectNode : SelectNode = selectNodeList.head; selectNode; selectNode = selectNode.next)
			{
				if (lastSelectedSelectNode == null ||
					selectNode.selectComponent.selectionIndex > lastSelectedSelectNode.selectComponent.selectionIndex)
				{
					lastSelectedSelectNode = selectNode;
				}
			}
			return lastSelectedSelectNode;
		}

		private function deselectAllSelectNodesWithSelectionIndexGreaterThan(selectionIndex : int) : void
		{
			for (var selectNode : SelectNode = selectNodeList.head; selectNode; selectNode = selectNode.next)
			{
				if (selectNode.selectComponent.selectionIndex > selectionIndex)
				{
					unselectSelectNode(selectNode);
				}
			}
		}

		private function selectSelectNode(selectNode : SelectNode) : void
		{
			var lastSelectedSelectNode : SelectNode = getLastSelectedSelectNode();
			selectNode.selectComponent.selectionIndex = lastSelectedSelectNode != null ? lastSelectedSelectNode.selectComponent.selectionIndex + 1 : 0;

			updateStatesOnAllSelectNodes();
		}

		private function unselectSelectNode(selectNode : SelectNode) : void
		{
			selectNode.selectComponent.selectionIndex = -1;

			updateStatesOnAllSelectNodes();
		}

		private function updateStatesOnAllSelectNodes() : void
		{
			for (var selectNode : SelectNode = selectNodeList.head; selectNode; selectNode = selectNode.next)
			{
				if (selectNode.selectComponent.selectionIndex >= 0)
				{
					selectNode.stateComponent.stateMachine.changeState("selected");
				}
				else
				{
					selectNode.stateComponent.stateMachine.changeState("idle");
				}
			}
		}
	}
}