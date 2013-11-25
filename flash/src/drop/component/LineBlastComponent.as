package drop.component
{
	import ash.tools.ComponentPool;

	public class LineBlastComponent
	{
		public var isTriggered : Boolean;

		public static function create() : LineBlastComponent
		{
			var component : LineBlastComponent = ComponentPool.get(LineBlastComponent);
			component.reset();
			return component;
		}

		public function reset() : void
		{
			isTriggered = false;
		}

		public function withIsTriggered(value : Boolean) : LineBlastComponent
		{
			isTriggered = value;
			return this;
		}
	}
}
