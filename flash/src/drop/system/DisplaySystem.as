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
		private var tileSize : int;

		private var displayNodeList : NodeList;

		public function DisplaySystem(displayObjectContainer : DisplayObjectContainer, tileSize : int)
		{
			this.displayObjectContainer = displayObjectContainer;
			this.tileSize = tileSize;
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

			for each (var displayComponentContainer : DisplayComponentContainer in displayNode.displayComponent.displayComponentContainers)
			{
				displayComponentContainer.addChild(displayComponentContainer.displayObject);
				displayObjectContainer.addChild(displayComponentContainer);
			}

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
			for each (var displayComponentContainer : DisplayComponentContainer in displayNode.displayComponent.displayComponentContainers)
			{
				displayObjectContainer.removeChild(displayComponentContainer);
			}
		}





		override public function update(time : Number) : void
		{
			super.update(time);

			for (var displayNode : DisplayNode = displayNodeList.head; displayNode; displayNode = displayNode.next)
			{
				updateTransform(displayNode);
				updateAnimation(displayNode, time);
			}
		}

		[Inline]
		private final function updateTransform(displayNode : DisplayNode) : void
		{
			for each (var displayComponentContainer : DisplayComponentContainer in displayNode.displayComponent.displayComponentContainers)
			{
				displayComponentContainer.x = int(displayNode.transformComponent.x + tileSize / 2);
				displayComponentContainer.y = int(displayNode.transformComponent.y + tileSize / 2);
				displayComponentContainer.scaleX = displayNode.transformComponent.scale;
				displayComponentContainer.scaleY = displayNode.transformComponent.scale;
			}
		}

		[Inline]
		private final function updateAnimation(displayNode : DisplayNode, time : Number) : void
		{
			for each (var displayComponentContainer : DisplayComponentContainer in displayNode.displayComponent.displayComponentContainers)
			{
				if (displayComponentContainer.displayObject is IAnimatable)
				{
					IAnimatable(displayComponentContainer.displayObject).advanceTime(time);
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