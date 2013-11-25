package drop.system
{
	import ash.core.*;
	import ash.fsm.*;

	public class SubmittingStateEndingSystem extends System
	{
		private var stateMachine : EngineStateMachine;

		public function SubmittingStateEndingSystem(engineStateMachine : EngineStateMachine)
		{
			this.stateMachine = engineStateMachine;
		}

		override public function update(time : Number) : void
		{
			stateMachine.changeState("matching");
		}
	}
}