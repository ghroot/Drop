package drop.system
{
	import ash.core.*;

	import drop.node.SelectNode;

	public class RemoveSelectionSystem extends System
	{
		private var engine : Engine;
		private var selectNodeList : NodeList;

		public function RemoveSelectionSystem()
		{
		}

		override public function addToEngine(engine : Engine) : void
		{
			this.engine = engine;
			selectNodeList = engine.getNodeList(SelectNode);
		}

		override public function update(time : Number) : void
		{
			for (var selectNode : SelectNode = selectNodeList.head as SelectNode; selectNode; selectNode = selectNode.next as SelectNode)
			{
				if (selectNode.selectComponent.selectionIndex >= 0)
				{
					engine.removeEntity(selectNode.entity);
				}
			}
		}
	}
}