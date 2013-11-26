package drop.node
{
	import ash.core.NodeList;

	public class SelectNodeUtils
	{
		public static function deselectSelectNodes(selectNodeList : NodeList) : void
		{
			for (var selectNode : SelectNode = selectNodeList.head; selectNode; selectNode = selectNode.next)
			{
				if (selectNode.selectComponent.isSelected)
				{
					selectNode.selectComponent.isSelected = false;
					selectNode.stateComponent.stateMachine.changeState("idle");
				}
			}
		}
	}
}
