package drop.system
{
	import ash.core.*;
	import ash.fsm.*;

	import drop.node.CountdownNode;
	import drop.node.MoveNode;

	public class CascadingStateEndingSystem extends System
	{
		private var stateMachine : EngineStateMachine;

		private var countdownNodeList : NodeList;
		private var moveNodeList : NodeList;

		public function CascadingStateEndingSystem(engineStateMachine : EngineStateMachine)
		{
			this.stateMachine = engineStateMachine;
		}

		override public function addToEngine(engine : Engine) : void
		{
			countdownNodeList = engine.getNodeList(CountdownNode);
			moveNodeList = engine.getNodeList(MoveNode);
		}

		override public function update(time : Number) : void
		{
			if (hasBoardSettled())
			{
				stateMachine.changeState("matching");
			}
		}

		private function hasBoardSettled() : Boolean
		{
			return areAllMoveNodesStill() &&
					noCountdownNodesAreActive();
		}

		private function areAllMoveNodesStill() : Boolean
		{
			for (var moveNode : MoveNode = moveNodeList.head; moveNode; moveNode = moveNode.next)
			{
				if (moveNode.moveComponent.accelerationX != 0 ||
						moveNode.moveComponent.accelerationY != 0)
				{
					return false;
				}
			}
			return true;
		}

		private function noCountdownNodesAreActive() : Boolean
		{
			return countdownNodeList.empty;
		}
	}
}