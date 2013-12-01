package drop.component
{
	import ash.tools.ComponentPool;

	import drop.data.ZOrder;

	import starling.display.DisplayObject;

	public class DisplayComponent
	{
		public var displayComponentContainer : DisplayComponentContainer;

		public static function create() : DisplayComponent
		{
			var component : DisplayComponent = ComponentPool.get(DisplayComponent);
			component.reset();
			return component;
		}

		public function reset() : void
		{
			displayComponentContainer = null;
		}

		public function withDisplayObject(value : DisplayObject) : DisplayComponent
		{
			displayComponentContainer = new DisplayComponentContainer(value, ZOrder.MIDDLE);
			return this;
		}

		public function withZ(value : int) : DisplayComponent
		{
			displayComponentContainer.z = value;
			return this;
		}
	}
}