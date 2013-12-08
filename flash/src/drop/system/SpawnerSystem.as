package drop.system
{
	import ash.core.*;

	import drop.board.EntityManager;
	import drop.component.MoveComponent;
	import drop.node.BlockNode;
	import drop.node.SpawnerNode;

	public class SpawnerSystem extends System
	{
		private var tileSize : int;
		private var entityManager : EntityManager;

		private var engine : Engine;
		private var spawnerNodeList : NodeList;
		private var blockNodeList : NodeList;

		public function SpawnerSystem(tileSize : int, entityManager : EntityManager)
		{
			this.tileSize = tileSize;
			this.entityManager = entityManager;
		}

		override public function addToEngine(engine : Engine) : void
		{
			this.engine = engine;
			spawnerNodeList = engine.getNodeList(SpawnerNode);
			blockNodeList = engine.getNodeList(BlockNode);
		}

		override public function update(time : Number) : void
		{
			for (var spawnerNode : SpawnerNode = spawnerNodeList.head; spawnerNode; spawnerNode = spawnerNode.next)
			{
				if (canEntityBeCreatedAt(spawnerNode))
				{
					var entity : Entity;
					var chanceToCreateLineBlast : int = getChanceToCreateLineBlast(spawnerNode);
					if (Math.random() * 101 <= chanceToCreateLineBlast)
					{
						entity = entityManager.createLineBlast(spawnerNode.transformComponent.x, spawnerNode.transformComponent.y - tileSize);
					}
					else
					{
						entity = entityManager.createTile(spawnerNode.transformComponent.x, spawnerNode.transformComponent.y - tileSize);
					}
					engine.addEntity(entity);

					var moveComponent : MoveComponent = entity.get(MoveComponent);
					moveComponent.accelerationY = MoveComponent.FALL_ACCELERATION;
					moveComponent.velocityY = MoveComponent.FALL_VELOCITY;
				}
			}
		}

		private function canEntityBeCreatedAt(spawnerNode : SpawnerNode) : Boolean
		{
			for (var blockNode : BlockNode = blockNodeList.head; blockNode; blockNode = blockNode.next)
			{
				if (blockNode.transformComponent.x == spawnerNode.transformComponent.x &&
						blockNode.transformComponent.y >= spawnerNode.transformComponent.y - tileSize &&
						blockNode.transformComponent.y <= spawnerNode.transformComponent.y)
				{
					return false;
				}
			}
			return true;
		}

		private function getChanceToCreateLineBlast(spawnerNode : SpawnerNode) : int
		{
			switch (spawnerNode.spawnerComponent.spawnerLevel)
			{
				case 1:
					return 0;
				case 2:
					return 5;
				case 3:
					return 10;
				default:
					return 15;
			}
		}
	}
}
