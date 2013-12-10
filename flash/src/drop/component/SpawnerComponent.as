package drop.component
{
	import ash.tools.ComponentPool;

	public class SpawnerComponent
	{
		public var spawnerLevel : int;

		public static function create() : SpawnerComponent
		{
			var component : SpawnerComponent = ComponentPool.get(SpawnerComponent);
			component.reset();
			return component;
		}

		public function reset() : void
		{
			spawnerLevel = 0;
		}

		public function withSpawnerLevel(value : int) : SpawnerComponent
		{
			spawnerLevel = value;
			return this;
		}
	}
}
