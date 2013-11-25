package drop.component
{
	import ash.tools.ComponentPool;

	public class SelectComponent
	{
		public var isSelected : Boolean;

		public static function create() : SelectComponent
		{
			var selectComponent : SelectComponent = ComponentPool.get(SelectComponent);
			selectComponent.reset();
			return selectComponent;
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
