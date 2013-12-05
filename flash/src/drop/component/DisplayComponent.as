package drop.component
{
	import ash.tools.ComponentPool;

	import drop.data.ZOrder;

	import starling.display.DisplayObject;

	public class DisplayComponent
	{
		public var displayComponentContainers : Vector.<DisplayComponentContainer>;

		public function DisplayComponent()
		{
			displayComponentContainers = new Vector.<DisplayComponentContainer>();
		}

		public static function create() : DisplayComponent
		{
			var component : DisplayComponent = ComponentPool.get(DisplayComponent);
			component.reset();
			return component;
		}

		public function reset() : void
		{
			displayComponentContainers.length = 0;
		}

		public function withDisplayObject(value : DisplayObject, z : int = ZOrder.MIDDLE) : DisplayComponent
		{
			displayComponentContainers[displayComponentContainers.length] = new DisplayComponentContainer(value, z);
			return this;
		}
	}
}