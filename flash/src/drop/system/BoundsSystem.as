package drop.system
{
	import ash.core.Engine;
	import ash.core.NodeList;
	import ash.core.System;

	import drop.node.BoundsNode;

	public class BoundsSystem extends System
	{
		private var engine : Engine;
		private var boundsNodeList : NodeList;

		public function BoundsSystem()
		{
		}

		override public function addToEngine(engine : Engine) : void
		{
			this.engine = engine;

			boundsNodeList = engine.getNodeList(BoundsNode);
		}

		override public function update(time : Number) : void
		{
			for (var boundsNode : BoundsNode = boundsNodeList.head; boundsNode; boundsNode = boundsNode.next)
			{
				if (isOutsideOfBounds(boundsNode))
				{
					engine.removeEntity(boundsNode.entity);
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
