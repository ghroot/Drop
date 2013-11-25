package drop.component
{
	import ash.tools.ComponentPool;

	public class SelectComponent
	{
		public var selectionIndex : int;

		public static function create() : SelectComponent
		{
			var selectComponent : SelectComponent = ComponentPool.get(SelectComponent);
			selectComponent.reset();
			return selectComponent;
		}

		public function reset() : void
		{
			selectionIndex = -1;
		}

		public function withSelectionIndex(value : int) : SelectComponent
		{
			selectionIndex = value;
			return this;
		}
	}
}
