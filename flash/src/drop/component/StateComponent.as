package drop.component
{
	import ash.fsm.EntityStateMachine;
	import ash.tools.ComponentPool;

	public class StateComponent
	{
		public var stateMachine : EntityStateMachine;

		public static function create() : StateComponent
		{
			var component : StateComponent = ComponentPool.get(StateComponent);
			component.reset();
			return component;
		}

		public function reset() : void
		{
			stateMachine = null;
		}

		public function withStateMachine(value : EntityStateMachine) : StateComponent
		{
			stateMachine = value;
			return this;
		}
	}
}