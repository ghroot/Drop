package drop.component
{
	import ash.tools.ComponentPool;

	public class LineBlastTargetComponent
	{
		public static function create() : LineBlastTargetComponent
		{
			var component : LineBlastTargetComponent = ComponentPool.get(LineBlastTargetComponent);
			component.reset();
			return component;
		}

		public function reset() : void
		{
		}
	}
}
