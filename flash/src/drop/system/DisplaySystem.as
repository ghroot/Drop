package drop.system
{
	import ash.core.Engine;
	import ash.core.Node;
	import ash.core.NodeList;
	import ash.core.System;

	import drop.node.DisplayNode;

	import starling.display.DisplayObjectContainer;

	public class DisplaySystem extends System
	{
		private var displayObjectContainer : DisplayObjectContainer;
		private var viewScale : Number;

		private var displayNodeList : NodeList;

		public function DisplaySystem(displayObjectContainer : DisplayObjectContainer, viewScale : Number)
		{
			this.displayObjectContainer = displayObjectContainer;
			this.viewScale = viewScale;
		}

		override public function addToEngine(engine : Engine) : void
		{
			super.addToEngine(engine);

			displayNodeList = engine.getNodeList(DisplayNode);

			for (var displayNode : DisplayNode = displayNodeList.head; displayNode; displayNode = displayNode.next)
			{
				addToDisplayObjectContainer(displayNode);
			}

			displayNodeList.nodeAdded.add(onNodeAdded);
			displayNodeList.nodeRemoved.add(onNodeRemoved);
		}

		override public function removeFromEngine(engine : Engine) : void
		{
			super.removeFromEngine(engine);

			displayNodeList.nodeAdded.remove(onNodeAdded);
			displayNodeList.nodeRemoved.remove(onNodeRemoved);
		}

		private function addToDisplayObjectContainer(displayNode : DisplayNode) : void
		{
			updateTransform(displayNode);

			displayObjectContainer.addChild(displayNode.displayComponent.displayObject);
		}

		private function removeFromDisplayObjectContainer(displayNode : DisplayNode) : void
		{
			displayObjectContainer.removeChild(displayNode.displayComponent.displayObject);	
		}

		private function updateTransform(displayNode : DisplayNode) : void
		{
			displayNode.displayComponent.displayObject.x = displayNode.transformComponent.x * viewScale;
			displayNode.displayComponent.displayObject.y = displayNode.transformComponent.y * viewScale;
		}

		override public function update(time : Number) : void
		{
			super.update(time);

			for (var displayNode : DisplayNode = displayNodeList.head; displayNode; displayNode = displayNode.next)
			{
				updateTransform(displayNode);
			}
		}

		private function onNodeAdded(node : Node) : void
		{
			addToDisplayObjectContainer(node as DisplayNode);
		}

		private function onNodeRemoved(node : Node) : void
		{
			removeFromDisplayObjectContainer(node as DisplayNode);
		}
	}
}