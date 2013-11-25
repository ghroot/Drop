package drop.system
{
	import ash.core.Engine;
	import ash.core.NodeList;
	import ash.core.System;

	import drop.node.SelectNode;

	import drop.node.SelectNode;

	public class DeselectSystem extends System
	{
		private var selectNodeList : NodeList;

		public function DeselectSystem()
		{
		}

		override public function addToEngine(engine : Engine) : void
		{
			selectNodeList = engine.getNodeList(SelectNode);
		}

		override public function update(time : Number) : void
		{
			for (var selectNode : SelectNode = selectNodeList.head; selectNode; selectNode = selectNode.next)
			{
				selectNode.selectComponent.isSelected = false;
				selectNode.stateComponent.stateMachine.changeState("idle");
			}
		}
	}
}
