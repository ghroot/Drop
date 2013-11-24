package drop.system
{
	import ash.core.*;

	import drop.component.MoveComponent;
	import drop.node.BlockNode;
	import drop.node.CountdownNode;
	import drop.node.MoveNode;
	import drop.node.SpawnerNode;
	import drop.util.PointUtils;

	import flash.geom.Point;

	public class MoveSystem extends System
	{
		private static const SLIDE_DIRECTION_LEFT : int = 1;
		private static const SLIDE_DIRECTION_RIGHT : int = 2;

		private var boardSize : Point;
		private var tileSize : int;

		private var moveNodeList : NodeList;
		private var blockNodeList : NodeList;
		private var spawnerNodeList : NodeList;

		public function MoveSystem(boardSize : Point, tileSize : int)
		{
			this.boardSize = boardSize;
			this.tileSize = tileSize;
		}

		override public function addToEngine(engine : Engine) : void
		{
			moveNodeList = engine.getNodeList(MoveNode);
			blockNodeList = engine.getNodeList(BlockNode);
			spawnerNodeList = engine.getNodeList(SpawnerNode);
		}

		override public function update(time : Number) : void
		{
			sortMoveNodeList();

			for (var moveNode : MoveNode = moveNodeList.head; moveNode; moveNode = moveNode.next)
			{
				if (isMoving(moveNode))
				{
					applyAccelerationAndVelocity(moveNode, time);

					if (shouldStopMoving(moveNode))
					{
						stopMoving(moveNode);
					}
				}

				if (!isMoving(moveNode) &&
						canMove(moveNode))
				{
					if (canFallDown(moveNode))
					{
						startFalling(moveNode);
					}
					else
					{
						tryStartSliding(moveNode);
					}
				}

				moveNode.moveComponent.momentumX = 0;
				moveNode.moveComponent.momentumY = 0;
			}
		}

		private function sortMoveNodeList() : void
		{
			moveNodeList.mergeSort(compareMoveNodes);
		}

		private function compareMoveNodes(moveNode1 : MoveNode, moveNode2 : MoveNode) : int
		{
			if (moveNode1.transformComponent.y > moveNode2.transformComponent.y)
			{
				return -1;
			}
			else if (moveNode1.transformComponent.y < moveNode2.transformComponent.y)
			{
				return 1;
			}
			else
			{
				return Math.random() < 0.5 ? 1 : -1;
			}
		}

		private function isMoving(moveNode : MoveNode) : Boolean
		{
			return moveNode.moveComponent.accelerationX != 0 ||
					moveNode.moveComponent.accelerationY != 0;
		}

		private function applyAccelerationAndVelocity(moveNode : MoveNode, time : Number) : void
		{
			moveNode.moveComponent.velocityX += moveNode.moveComponent.accelerationX;
			moveNode.moveComponent.velocityY += moveNode.moveComponent.accelerationY;

			var velocityLength : Number = PointUtils.getLength(moveNode.moveComponent.velocityX, moveNode.moveComponent.velocityY);
			if (velocityLength > MoveComponent.MAX_VELOCITY)
			{
				moveNode.moveComponent.velocityX /= velocityLength;
				moveNode.moveComponent.velocityY /= velocityLength;
				moveNode.moveComponent.velocityX *= MoveComponent.MAX_VELOCITY;
				moveNode.moveComponent.velocityY *= MoveComponent.MAX_VELOCITY;
			}

			moveNode.transformComponent.x += moveNode.moveComponent.velocityX * time;
			moveNode.transformComponent.y += moveNode.moveComponent.velocityY * time;

			updatePreviousPositionThatMoveNodeIsMovingTowards(moveNode);
			updatePositionThatMoveNodeIsMovingTowards(moveNode);
		}

		private function shouldStopMoving(moveNode : MoveNode) : Boolean
		{
			return slideWasCompleted(moveNode) ||
					!canMoveNodeMoveTo(moveNode, moveNode.moveComponent.movingTowardsX, moveNode.moveComponent.movingTowardsY);
		}

		private function slideWasCompleted(moveNode : MoveNode) : Boolean
		{
			return (moveNode.moveComponent.accelerationX > 0 &&
					moveNode.transformComponent.x >= moveNode.moveComponent.slidingTowardsPositionX) ||
					(moveNode.moveComponent.accelerationX < 0 &&
					moveNode.transformComponent.x <= moveNode.moveComponent.slidingTowardsPositionX);
		}

		private function startFalling(moveNode : MoveNode) : void
		{
			moveNode.moveComponent.accelerationY = MoveComponent.FALL_ACCELERATION;

			if (moveNode.moveComponent.momentumX != 0 ||
					moveNode.moveComponent.momentumY != 0)
			{
				moveNode.moveComponent.velocityY = PointUtils.getLength(moveNode.moveComponent.momentumX, moveNode.moveComponent.momentumY);
			}
			else
			{
				moveNode.moveComponent.velocityY = MoveComponent.FALL_VELOCITY;
			}

			updatePreviousPositionThatMoveNodeIsMovingTowards(moveNode);
			updatePositionThatMoveNodeIsMovingTowards(moveNode);
		}

		private function stopMoving(moveNode : MoveNode) : void
		{
			moveNode.moveComponent.momentumX = moveNode.moveComponent.velocityX;
			moveNode.moveComponent.momentumY = moveNode.moveComponent.velocityY;

			moveNode.moveComponent.velocityX = 0;
			moveNode.moveComponent.velocityY = 0;
			moveNode.moveComponent.accelerationX = 0;
			moveNode.moveComponent.accelerationY = 0;

			moveNode.moveComponent.previousMovingTowardsX = Number.MIN_VALUE;
			moveNode.moveComponent.previousMovingTowardsY = Number.MIN_VALUE;
			moveNode.moveComponent.movingTowardsX = Number.MIN_VALUE;
			moveNode.moveComponent.movingTowardsY = Number.MIN_VALUE;
			moveNode.moveComponent.slidingTowardsPositionX = 0;

			snapToClosestWholeTilePosition(moveNode);
		}

		private function tryStartSliding(moveNode : MoveNode) : void
		{
			var random : int = int(Math.random() * 2);
			var considerSlidingLeft : Boolean = canSlideLeft(moveNode);
			var considerSlidingRight : Boolean = considerSlidingLeft && random == 0 ? false : canSlideRight(moveNode);
			if (considerSlidingLeft &&
					(!considerSlidingRight || random == 0))
			{
				startSliding(moveNode, SLIDE_DIRECTION_LEFT);
			}
			else if (considerSlidingRight &&
					(!considerSlidingLeft || random == 1))
			{
				startSliding(moveNode, SLIDE_DIRECTION_RIGHT);
			}
		}

		private function startSliding(moveNode : MoveNode, direction : int) : void
		{
			moveNode.moveComponent.accelerationX = direction == SLIDE_DIRECTION_LEFT ? -MoveComponent.SLIDE_ACCELERATION : MoveComponent.SLIDE_ACCELERATION;
			moveNode.moveComponent.accelerationY = MoveComponent.SLIDE_ACCELERATION;

			var momentumLength : Number = PointUtils.getLength(moveNode.moveComponent.momentumX, moveNode.moveComponent.momentumY);
			if (momentumLength > 0)
			{
				moveNode.moveComponent.velocityX = direction == SLIDE_DIRECTION_LEFT ? -momentumLength / 2 : momentumLength / 2;
				moveNode.moveComponent.velocityY = momentumLength / 2;
			}
			else
			{
				moveNode.moveComponent.velocityX = direction == SLIDE_DIRECTION_LEFT ? -MoveComponent.SLIDE_VELOCITY : MoveComponent.SLIDE_VELOCITY;
				moveNode.moveComponent.velocityY = MoveComponent.SLIDE_VELOCITY;
			}

			updatePreviousPositionThatMoveNodeIsMovingTowards(moveNode);
			updatePositionThatMoveNodeIsMovingTowards(moveNode);
			moveNode.moveComponent.slidingTowardsPositionX = moveNode.moveComponent.movingTowardsX;
		}

		private function snapToClosestWholeTilePosition(moveNode : MoveNode) : void
		{
			moveNode.transformComponent.x = Math.round(moveNode.transformComponent.x / tileSize) * tileSize;
			moveNode.transformComponent.y = Math.round(moveNode.transformComponent.y / tileSize) * tileSize;
		}

		private function canFallDown(moveNode : MoveNode) : Boolean
		{
			var moveNodeCanMove : Boolean = canMoveNodeMoveTo(moveNode, moveNode.transformComponent.x, moveNode.transformComponent.y + tileSize);
			return moveNodeCanMove;
		}

		private function canSlideLeft(moveNode : MoveNode) : Boolean
		{
			return canSlide(moveNode, -tileSize);
		}

		private function canSlideRight(moveNode : MoveNode) : Boolean
		{
			return canSlide(moveNode, tileSize);
		}

		private function canSlide(moveNode : MoveNode, horizontalOffset : Number) : Boolean
		{
			var x : Number = moveNode.transformComponent.x + horizontalOffset;
			var y : Number = moveNode.transformComponent.y + tileSize;
			return canMoveNodeMoveTo(moveNode, moveNode.transformComponent.x + horizontalOffset, moveNode.transformComponent.y + tileSize) &&
					hasNonMovingBlockNodesUnderneath(moveNode) && !canBeFilledFromAbove(x, y);
		}

		private function hasNonMovingBlockNodesUnderneath(moveNode : MoveNode) : Boolean
		{
			for (var positionY : Number = moveNode.transformComponent.y + tileSize; positionY < boardSize.y * tileSize; positionY += tileSize)
			{
				var blockNode : BlockNode = getBlockNodeAtPosition(moveNode.transformComponent.x, positionY);
				if (blockNode == null)
				{
					return false;
				}
				else
				{
					var moveComponent : MoveComponent = blockNode.entity.get(MoveComponent);
					if (moveComponent != null &&
							(moveComponent.accelerationX != 0 ||
									moveComponent.accelerationY != 0))
					{
						return false;
					}
				}
			}
			return true;
		}

		private function canBeFilledFromAbove(x : Number, y : Number) : Boolean
		{
			y -= tileSize;
			while (y >= 0)
			{
				if (getStaticBlockNodeAtPosition(x, y) != null)
				{
					return false;
				}

				if (getSpawnerNodeAtPosition(x, y) != null ||
						getMoveNodeAtPosition(x, y) != null ||
						hasMoveNodesMovingTowards(x, y))
				{
					return true;
				}

				y -= tileSize;
			}
			return false;
		}

		private function hasMoveNodesMovingTowards(x : Number, y : Number, entity : Entity = null) : Boolean
		{
			for (var moveNode : MoveNode = moveNodeList.head; moveNode; moveNode = moveNode.next)
			{
				if (moveNode.moveComponent.movingTowardsX == x &&
						moveNode.moveComponent.movingTowardsY == y &&
						(entity == null || entity != moveNode.entity))
				{
					return true;
				}
			}
			return false;
		}

		private function updatePositionThatMoveNodeIsMovingTowards(moveNode : MoveNode) : void
		{
			var x : Number = int((moveNode.transformComponent.x + tileSize / 2) / tileSize) * tileSize;
			var y : Number = int((moveNode.transformComponent.y + tileSize / 2) / tileSize) * tileSize;
			var centerRelativePositionX : Number = (moveNode.transformComponent.x + tileSize / 2) % tileSize;
			var centerRelativePositionY : Number = (moveNode.transformComponent.y + tileSize / 2) % tileSize;
			if (moveNode.moveComponent.accelerationX > 0 &&
					centerRelativePositionX >= tileSize / 2)
			{
				x += tileSize;
			}
			else if (moveNode.moveComponent.accelerationX < 0 &&
					centerRelativePositionX <= tileSize / 2)
			{
				x -= tileSize;
			}
			if (moveNode.moveComponent.accelerationY > 0 &&
					centerRelativePositionY >= tileSize / 2)
			{
				y += tileSize;
			}
			else if (moveNode.moveComponent.accelerationY < 0 &&
					centerRelativePositionY <= tileSize / 2)
			{
				y -= tileSize;
			}
			moveNode.moveComponent.movingTowardsX = x;
			moveNode.moveComponent.movingTowardsY = y;
		}

		private function updatePreviousPositionThatMoveNodeIsMovingTowards(moveNode : MoveNode) : void
		{
			moveNode.moveComponent.previousMovingTowardsX = moveNode.moveComponent.movingTowardsX;
			moveNode.moveComponent.previousMovingTowardsY = moveNode.moveComponent.movingTowardsY;
		}

		private function canMove(moveNode : MoveNode) : Boolean
		{
			return !isAtBottomEdge(moveNode);
		}

		private function isAtBottomEdge(moveNode : MoveNode) : Boolean
		{
			return moveNode.transformComponent.y >= (boardSize.y - 1) * tileSize;
		}

		private function canMoveNodeMoveTo(moveNode : MoveNode, x : Number, y : Number) : Boolean
		{
			if (!isPositionOnBoard(x, y))
			{
				return false;
			}

			var blockNode : BlockNode = getBlockNodeAtPosition(x, y);
			if (blockNode != null &&
				blockNode.entity != moveNode.entity)
			{
				return false;
			}

			if (hasMoveNodesMovingTowards(x, y, moveNode.entity))
			{
				return false;
			}

			return true;
		}

		private function isPositionOnBoard(x : Number, y : Number) : Boolean
		{
			return !(x < 0 ||
					x > (boardSize.x - 1) * tileSize ||
					y < 0 ||
					y > (boardSize.y - 1) * tileSize);
		}

		private function getBlockNodeAtPosition(x : Number, y : Number) : BlockNode
		{
			for (var blockNode : BlockNode = blockNodeList.head; blockNode; blockNode = blockNode.next)
			{
				if (blockNode.transformComponent.x == x &&
						blockNode.transformComponent.y == y)
				{
					return blockNode;
				}
			}
			return null;
		}

		private function getStaticBlockNodeAtPosition(x : Number, y : Number) : BlockNode
		{
			var blockNode : BlockNode = getBlockNodeAtPosition(x, y);
			if (blockNode != null &&
				blockNode.entity.get(CountdownNode) == null &&
				blockNode.entity.get(MoveComponent) == null)
			{
				return blockNode;
			}
			else
			{
				return null;
			}
		}

		private function getMoveNodeAtPosition(x : Number, y : Number) : MoveNode
		{
			for (var moveNode : MoveNode = moveNodeList.head; moveNode; moveNode = moveNode.next)
			{
				if (moveNode.transformComponent.x == x &&
						moveNode.transformComponent.y == y)
				{
					return moveNode;
				}
			}
			return null;
		}

		private function getSpawnerNodeAtPosition(x : Number, y : Number) : SpawnerNode
		{
			for (var spawnerNode : SpawnerNode = spawnerNodeList.head; spawnerNode; spawnerNode = spawnerNode.next)
			{
				if (spawnerNode.transformComponent.x == x &&
						spawnerNode.transformComponent.y == y)
				{
					return spawnerNode;
				}
			}
			return null;
		}
	}
}
