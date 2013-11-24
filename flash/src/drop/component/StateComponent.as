package drop.component
{
	import ash.fsm.EntityStateMachine;

	public class StateComponent
	{
		public var stateMachine : EntityStateMachine;

		public function StateComponent(stateMachine : EntityStateMachine = null)
		{
			this.stateMachine = stateMachine;
		}
	}
}