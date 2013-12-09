package drop.component
{
	import ash.tools.ComponentPool;

	public class TypeComponent
	{
		public var type : String;

		public static function create() : TypeComponent
		{
			var component : TypeComponent = ComponentPool.get(TypeComponent);
			component.reset();
			return component;
		}

		public function reset() : void
		{
			type = null;
		}

		public function withType(value : String) : TypeComponent
		{
			type = value;
			return this;
		}
	}
}
