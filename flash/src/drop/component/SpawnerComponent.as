package drop.component
{
	import ash.tools.ComponentPool;

	public class SpawnerComponent
	{
		public static function create() : SpawnerComponent
		{
			var component : SpawnerComponent = ComponentPool.get(SpawnerComponent);
			component.reset();
			return component;
		}

		public function reset() : void
		{
		}
	}
}
