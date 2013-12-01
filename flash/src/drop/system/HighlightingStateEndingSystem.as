package drop.system
{
	import ash.core.Engine;
	import ash.core.System;
	import ash.fsm.EngineStateMachine;

	import drop.data.Countdown;

	public class HighlightingStateEndingSystem extends System
	{
		private var stateMachine : EngineStateMachine;

		private var countdown : Countdown;

		public function HighlightingStateEndingSystem(stateMachine : EngineStateMachine)
		{
			this.stateMachine = stateMachine;

			countdown = new Countdown();
		}

		override public function addToEngine(engine : Engine) : void
		{
			countdown.resetWithTime(5);
		}

		override public function update(time : Number) : void
		{
			if (countdown.countdownAndReturnIfReachedZero(time))
			{
				stateMachine.changeState("cascading");
			}
		}
	}
}
