package drop.system
{
	import ash.core.Engine;
	import ash.core.NodeList;
	import ash.core.System;

	import drop.node.LineBlastPulseNode;
	import drop.node.LineBlastTargetNode;

	public class LineBlastPulseSystem extends System
	{
		private var tileSize : int;

		private var lineBlastPulseNodeList : NodeList;
		private var lineBlastTargetNodeList : NodeList;

		public function LineBlastPulseSystem(tileSize : int)
		{
			this.tileSize = tileSize;
		}

		override public function addToEngine(engine : Engine) : void
		{
			lineBlastPulseNodeList = engine.getNodeList(LineBlastPulseNode);
			lineBlastTargetNodeList = engine.getNodeList(LineBlastTargetNode);
		}

		override public function update(time : Number) : void
		{
			for (var lineBlastTargetNode : LineBlastTargetNode = lineBlastTargetNodeList.head; lineBlastTargetNode; lineBlastTargetNode = lineBlastTargetNode.next)
			{
				if (touchesAnyLineBlastPulseNode(lineBlastTargetNode.transformComponent.x, lineBlastTargetNode.transformComponent.y))
				{
					lineBlastTargetNode.stateComponent.stateMachine.changeState("destroyedByLineBlast");
				}
			}
		}

		private function touchesAnyLineBlastPulseNode(x : Number, y : Number) : Boolean
		{
			for (var lineBlastPulseNode : LineBlastPulseNode = lineBlastPulseNodeList.head; lineBlastPulseNode; lineBlastPulseNode = lineBlastPulseNode.next)
			{
				if (isIntersecting(lineBlastPulseNode.transformComponent.x, lineBlastPulseNode.transformComponent.y, x, y))
				{
					return true;
				}
			}
			return false;
		}

		private function isIntersecting(x1 : Number, y1 : Number, x2 : Number, y2 : Number) : Boolean
		{
			return !(x1 < x2 ||
					x1 >= x2 + tileSize ||
					y1 < y2 ||
					y1 >= y2 + tileSize);
		}
	}
}
