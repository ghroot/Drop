package drop.component.script
{
	import ash.tools.ComponentPool;

	public class ScriptComponent
	{
		public var scripts : Vector.<Script>;

		public function ScriptComponent()
		{
			scripts = new Vector.<Script>();
		}

		public static function create() : ScriptComponent
		{
			var component : ScriptComponent = ComponentPool.get(ScriptComponent);
			component.reset();
			return component;
		}

		public function reset() : void
		{
			scripts.length = 0;
		}

		public function withScript(script : Script) : ScriptComponent
		{
			scripts[scripts.length] = script;
			return this;
		}
	}
}
