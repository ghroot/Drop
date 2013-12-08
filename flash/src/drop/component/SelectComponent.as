package drop.component
{
	import ash.tools.ComponentPool;

	public class SelectComponent
	{
		public var isSelected : Boolean;

		public static function create() : SelectComponent
		{
			var component : SelectComponent = ComponentPool.get(SelectComponent);
			component.reset();
			return component;
		}

		public function reset() : void
		{
			isSelected = false;
		}

		public function withIsSelected(value : Boolean) : SelectComponent
		{
			isSelected = value;
			return this;
		}
	}
}
