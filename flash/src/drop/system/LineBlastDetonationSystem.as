package drop.system
{
	import ash.core.Engine;
	import ash.core.NodeList;
	import ash.core.System;

	import drop.board.EntityManager;
	import drop.component.MatchComponent;
	import drop.data.GameState;
	import drop.node.LineBlastNode;
	import drop.node.LineBlastTargetNode;

	import flash.geom.Point;

	public class LineBlastDetonationSystem extends System
	{
		private var entityManager : EntityManager;
		private var boardSize : Point;
		private var tileSize : int;
		private var gameState : GameState;

		private var engine : Engine;
		private var lineBlastNodeList : NodeList;
		private var lineBlastTargetNodeList : NodeList;

		public function LineBlastDetonationSystem(entityManager : EntityManager, boardSize : Point, tileSize : int, gameState : GameState)
		{
			this.entityManager = entityManager;
			this.boardSize = boardSize;
			this.tileSize = tileSize;
			this.gameState = gameState;
		}

		override public function addToEngine(engine : Engine) : void
		{
			this.engine = engine;

			lineBlastNodeList = engine.getNodeList(LineBlastNode);
			lineBlastTargetNodeList = engine.getNodeList(LineBlastTargetNode);
		}

		override public function update(time : Number) : void
		{
			var lineBlastCenterX : Number;
			var lineBlastCenterY : Number;

			for (var lineBlastNode : LineBlastNode = lineBlastNodeList.head; lineBlastNode; lineBlastNode = lineBlastNode.next)
			{
				if (lineBlastNode.lineBlastComponent.isTriggered)
				{
					var matchComponent : MatchComponent = lineBlastNode.entity.get(MatchComponent);
					engine.addEntity(entityManager.createLineBlastPulse(lineBlastNode.transformComponent.x,
							lineBlastNode.transformComponent.y, matchComponent.color));

					lineBlastCenterX = lineBlastNode.transformComponent.x + tileSize / 2;
					lineBlastCenterY = lineBlastNode.transformComponent.y + tileSize / 2;

					for (var lineBlastTargetNode : LineBlastTargetNode = lineBlastTargetNodeList.head; lineBlastTargetNode; lineBlastTargetNode = lineBlastTargetNode.next)
					{
						if ((lineBlastTargetNode.transformComponent.x <= lineBlastCenterX &&
								lineBlastTargetNode.transformComponent.x + tileSize >= lineBlastCenterX) ||
								(lineBlastTargetNode.transformComponent.y <= lineBlastCenterY &&
								lineBlastTargetNode.transformComponent.y + tileSize >= lineBlastCenterY))
						{
							lineBlastTargetNode.stateComponent.stateMachine.changeState("destroyedByLineBlast");

							gameState.credits++;
						}
					}

					for (var positionX : Number = 0; positionX < boardSize.x * tileSize; positionX += tileSize)
					{
						for (var positionY : Number = 0; positionY < boardSize.y * tileSize; positionY += tileSize)
						{
							if (positionX == lineBlastNode.transformComponent.x ||
									positionY == lineBlastNode.transformComponent.y)
							{
								engine.addEntity(entityManager.createInvisibleBlocker(positionX, positionY, 0.5));
							}
						}
					}

					entityManager.destroyEntity(lineBlastNode.entity);
				}
			}
		}
	}
}
