package drop.component
{
	import ash.tools.ComponentPool;

	public class TransformComponent
	{
		public var x : Number;
		public var y : Number;
		public var scale : Number;

		public static function create() : TransformComponent
		{
			var component : TransformComponent = ComponentPool.get(TransformComponent);
			component.reset();
			return component;
		}

		public function reset() : void
		{
			x = 0;
			y = 0;
			scale = 1;
		}

		public function withX(value : Number) : TransformComponent
		{
			x = value;
			return this;
		}

		public function withY(value : Number) : TransformComponent
		{
			y = value;
			return this;
		}

		public function withScale(value : Number) : TransformComponent
		{
			scale = value;
			return this;
		}
	}
}
