package drop.component
{
	import ash.tools.ComponentPool;

	public class FlyComponent
	{
		public var velocityX : Number;
		public var velocityY : Number;

		public static function create() : FlyComponent
		{
			var component : FlyComponent = ComponentPool.get(FlyComponent);
			component.reset();
			return component;
		}

		public function reset() : void
		{
			velocityX = 0;
			velocityY = 0;
		}

		public function withVelocityX(value : Number) : FlyComponent
		{
			velocityX = value;
			return this;
		}

		public function withVelocityY(value : Number) : FlyComponent
		{
			velocityY = value;
			return this;
		}
	}
}
