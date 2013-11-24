package drop.system
{
	import ash.core.Engine;
	import ash.core.NodeList;
	import ash.core.System;

	import drop.EntityManager;

	import drop.node.BoundsNode;

	public class BoundsSystem extends System
	{
		private var entityManager : EntityManager;
		private var boundsNodeList : NodeList;

		public function BoundsSystem(entityManager : EntityManager)
		{
			this.entityManager = entityManager;
		}

		override public function addToEngine(engine : Engine) : void
		{
			boundsNodeList = engine.getNodeList(BoundsNode);
		}

		override public function update(time : Number) : void
		{
			for (var boundsNode : BoundsNode = boundsNodeList.head; boundsNode; boundsNode = boundsNode.next)
			{
				if (isOutsideOfBounds(boundsNode))
				{
					entityManager.destroyEntity(boundsNode.entity);
				}
			}
		}

		private function isOutsideOfBounds(boundsNode : BoundsNode) : Boolean
		{
			return boundsNode.transformComponent.x < boundsNode.boundsComponent.x ||
					boundsNode.transformComponent.x >= boundsNode.boundsComponent.x + boundsNode.boundsComponent.width ||
					boundsNode.transformComponent.y < boundsNode.boundsComponent.y ||
					boundsNode.transformComponent.y >= boundsNode.boundsComponent.y + boundsNode.boundsComponent.height;
		}
	}
}
