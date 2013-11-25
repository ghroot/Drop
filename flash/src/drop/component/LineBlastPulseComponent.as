package drop.component
{
	import ash.tools.ComponentPool;

	public class LineBlastPulseComponent
	{
		public static function create() : LineBlastPulseComponent
		{
			var component : LineBlastPulseComponent = ComponentPool.get(LineBlastPulseComponent);
			component.reset();
			return component;
		}

		public function reset() : void
		{
		}
	}
}
