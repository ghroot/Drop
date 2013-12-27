package drop.system
{
	import ash.core.Engine;
	import ash.core.System;
	import ash.fsm.EngineStateMachine;

	import drop.data.Countdown;
	import drop.node.GameNode;

	public class HighlightingStateEndingSystem extends System
	{
		private var stateMachine : EngineStateMachine;

		private var gameNode : GameNode;
		private var countdown : Countdown;

		public function HighlightingStateEndingSystem(stateMachine : EngineStateMachine)
		{
			this.stateMachine = stateMachine;

			countdown = new Countdown();
		}

		override public function addToEngine(engine : Engine) : void
		{
			gameNode = engine.getNodeList(GameNode).head;

			countdown.resetWithTime(5);
		}

		override public function update(time : Number) : void
		{
			if (countdown.countdownAndReturnIfReachedZero(time))
			{
//				gameNode.gameStateComponent.matchInfosToHighlight.shift();
				gameNode.gameStateComponent.matchInfosToHighlight.length = 0;
				if (gameNode.gameStateComponent.matchInfosToHighlight.length > 0)
				{
					stateMachine.changeState("highlighting");
				}
				else
				{
					stateMachine.changeState("cascading");
				}
			}
		}
	}
}
