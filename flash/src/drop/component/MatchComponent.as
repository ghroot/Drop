package drop.component
{
	import ash.tools.ComponentPool;

	public class MatchComponent
	{
		public var color : int;

		public static function create() : MatchComponent
		{
			var component : MatchComponent = ComponentPool.get(MatchComponent);
			component.reset();
			return component;
		}

		public function reset() : void
		{
			color = 0;
		}

		public function withColor(value : int) : MatchComponent
		{
			color = value;
			return this;
		}
	}
}
