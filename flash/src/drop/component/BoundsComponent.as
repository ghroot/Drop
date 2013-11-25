package drop.component
{
	import ash.tools.ComponentPool;

	public class BoundsComponent
	{
		public var x : Number;
		public var y : Number;
		public var width : Number;
		public var height : Number;

		public static function create() : BoundsComponent
		{
			var component : BoundsComponent = ComponentPool.get(BoundsComponent);
			component.reset();
			return component;
		}

		public function reset() : void
		{
			x = 0;
			y = 0;
			width = 0;
			height = 0;
		}

		public function withX(value : Number) : BoundsComponent
		{
			x = value;
			return this;
		}

		public function withY(value : Number) : BoundsComponent
		{
			y = value;
			return this;
		}

		public function withWidth(value : Number) : BoundsComponent
		{
			width = value;
			return this;
		}

		public function withHeight(value : Number) : BoundsComponent
		{
			height = value;
			return this;
		}
	}
}
