package drop.component
{
	import ash.tools.ComponentPool;

	public class MatchComponent
	{
		public var type : int;

		public static function create() : MatchComponent
		{
			var component : MatchComponent = ComponentPool.get(MatchComponent);
			component.reset();
			return component;
		}

		public function reset() : void
		{
			type = 0;
		}

		public function withType(value : int) : MatchComponent
		{
			type = value;
			return this;
		}
	}
}
