package drop.system
{
	import ash.core.Engine;
	import ash.core.Node;
	import ash.core.NodeList;
	import ash.core.System;

	import drop.component.DisplayComponentContainer;
	import drop.node.DisplayNode;

	import starling.animation.IAnimatable;
	import starling.display.DisplayObjectContainer;

	public class DisplaySystem extends System
	{
		private var displayObjectContainer : DisplayObjectContainer;
		private var scaleFactor : Number;
		private var viewTileSize : int;

		private var displayNodeList : NodeList;

		public function DisplaySystem(displayObjectContainer : DisplayObjectContainer, scaleFactor : Number, viewTileSize : int)
		{
			this.displayObjectContainer = displayObjectContainer;
			this.scaleFactor = scaleFactor;
			this.viewTileSize = viewTileSize;
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

			displayNode.displayComponent.displayComponentContainer.addChild(displayNode.displayComponent.displayComponentContainer.displayObject);
			displayObjectContainer.addChild(displayNode.displayComponent.displayComponentContainer);
			displayObjectContainer.sortChildren(compareDisplayObjectsByZ);
		}

		private function compareDisplayObjectsByZ(displayComponentContainer1 : DisplayComponentContainer, displayComponentContainer2 : DisplayComponentContainer) : int
		{
			if (displayComponentContainer1.z < displayComponentContainer2.z)
			{
				return -1;
			}
			else if (displayComponentContainer1.z > displayComponentContainer2.z)
			{
				return 1;
			}
			else
			{
				return 0;
			}
		}

		private function removeFromDisplayObjectContainer(displayNode : DisplayNode) : void
		{
			displayObjectContainer.removeChild(displayNode.displayComponent.displayComponentContainer);
		}

		private function updateTransform(displayNode : DisplayNode) : void
		{
			displayNode.displayComponent.displayComponentContainer.x = int(displayNode.transformComponent.x * scaleFactor + viewTileSize / 2);
			displayNode.displayComponent.displayComponentContainer.y = int(displayNode.transformComponent.y * scaleFactor + viewTileSize / 2);
			displayNode.displayComponent.displayComponentContainer.scaleX = displayNode.transformComponent.scale;
			displayNode.displayComponent.displayComponentContainer.scaleY = displayNode.transformComponent.scale;
		}

		override public function update(time : Number) : void
		{
			super.update(time);

			for (var displayNode : DisplayNode = displayNodeList.head; displayNode; displayNode = displayNode.next)
			{
				updateTransform(displayNode);

				if (displayNode.displayComponent.displayComponentContainer.displayObject is IAnimatable)
				{
					IAnimatable(displayNode.displayComponent.displayComponentContainer.displayObject).advanceTime(time);
				}
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