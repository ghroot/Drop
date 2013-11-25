package drop.component
{
	import ash.tools.ComponentPool;

	import starling.display.DisplayObject;

	public class DisplayComponent
	{
		public var displayObject : DisplayObject;

		public static function create() : DisplayComponent
		{
			var component : DisplayComponent = ComponentPool.get(DisplayComponent);
			component.reset();
			return component;
		}

		public function reset() : void
		{
			displayObject = null;
		}

		public function withDisplayObject(value : DisplayObject) : DisplayComponent
		{
			displayObject = value;
			return this;
		}
	}
}