package drop.system
{
	import ash.core.Engine;
	import ash.core.NodeList;
	import ash.core.System;

	import drop.EntityManager;
	import drop.node.LineBlastNode;

	import flash.geom.Point;

	public class LineBlastDetonationSystem extends System
	{
		private var entityManager : EntityManager;

		private var engine : Engine;
		private var lineBlastNodeList : NodeList;

		public function LineBlastDetonationSystem(entityManager : EntityManager)
		{
			this.entityManager = entityManager;
		}

		override public function addToEngine(engine : Engine) : void
		{
			this.engine = engine;

			lineBlastNodeList = engine.getNodeList(LineBlastNode);
		}

		override public function update(time : Number) : void
		{
			for (var lineBlastNode : LineBlastNode = lineBlastNodeList.head; lineBlastNode; lineBlastNode = lineBlastNode.next)
			{
				if (lineBlastNode.lineBlastComponent.isTriggered)
				{
					lineBlastNode.stateComponent.stateMachine.changeState("detonated");

					for each (var blastDirection : Point in [new Point(-1, 0), new Point(1, 0), new Point(0, -1), new Point(0, 1)])
					{
						engine.addEntity(entityManager.createLineBlastPulse(lineBlastNode.transformComponent.x, lineBlastNode.transformComponent.y, blastDirection.x, blastDirection.y));
					}
				}
			}
		}
	}
}
