package drop.system
{
	import ash.core.Engine;
	import ash.core.NodeList;
	import ash.core.System;

	import drop.node.FlyNode;

	public class FlySystem extends System
	{
		private var flyNodeList : NodeList;
		
		public function FlySystem()
		{
		}

		override public function addToEngine(engine : Engine) : void
		{
			flyNodeList = engine.getNodeList(FlyNode);
		}

		override public function update(time : Number) : void
		{
			for (var flyNode : FlyNode = flyNodeList.head; flyNode; flyNode = flyNode.next)
			{
				flyNode.transformComponent.x += flyNode.flyComponent.velocityX;
				flyNode.transformComponent.y += flyNode.flyComponent.velocityY;
			}
		}
	}
}
