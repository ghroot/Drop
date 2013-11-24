package drop.system
{
	import ash.core.*;
	import ash.fsm.*;

	public class SubmittingStateEndingSystem extends System
	{
		private var engineStateMachine : EngineStateMachine;

		public function SubmittingStateEndingSystem(engineStateMachine : EngineStateMachine)
		{
			this.engineStateMachine = engineStateMachine;
		}

		override public function update(time : Number) : void
		{
			engineStateMachine.changeState("cascading");
		}
	}
}