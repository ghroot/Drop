package drop.system
{
	import ash.core.*;

	import drop.node.SelectNode;

	public class MatchingSystem extends System
	{
		private var selectNodeList : NodeList;

		public function MatchingSystem()
		{
		}

		override public function addToEngine(engine : Engine) : void
		{
			selectNodeList = engine.getNodeList(SelectNode);
		}

		override public function update(time : Number) : void
		{
			for (var selectNode : SelectNode = selectNodeList.head as SelectNode; selectNode; selectNode = selectNode.next as SelectNode)
			{
				if (selectNode.selectComponent.selectionIndex >= 0)
				{
					selectNode.stateComponent.stateMachine.changeState("matched");
				}
			}
		}
	}
}