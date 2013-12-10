package drop.system
{
	import ash.core.System;
	import ash.fsm.EngineStateMachine;

	public class TurnStartStateEndingSystem extends System
	{
		private var stateMachine : EngineStateMachine;

		public function TurnStartStateEndingSystem(stateMachine : EngineStateMachine)
		{
			this.stateMachine = stateMachine;
		}

		override public function update(time : Number) : void
		{
			stateMachine.changeState("selecting");
		}
	}
}
