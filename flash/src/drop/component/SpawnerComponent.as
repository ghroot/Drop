package drop.component
{
	import ash.tools.ComponentPool;

	import drop.data.SpawnerLevel;

	public class SpawnerComponent
	{
		public var spawnerLevel : SpawnerLevel;

		public static function create() : SpawnerComponent
		{
			var component : SpawnerComponent = ComponentPool.get(SpawnerComponent);
			component.reset();
			return component;
		}

		public function reset() : void
		{
			spawnerLevel = new SpawnerLevel(1);
		}

		public function withLevel(value : int) : SpawnerComponent
		{
			spawnerLevel.level = value;
			return this;
		}
	}
}
