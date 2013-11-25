package drop.component
{
	import ash.tools.ComponentPool;

	public class BlockComponent
	{
		public static function create() : BlockComponent
		{
			var component : BlockComponent = ComponentPool.get(BlockComponent);
			component.reset();
			return component;
		}

		public function reset() : void
		{
		}
	}
}
