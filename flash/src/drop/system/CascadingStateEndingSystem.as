package drop.system
{
	import ash.core.*;
	import ash.fsm.*;

	import drop.node.CountdownNode;
	import drop.node.MoveNode;

	public class CascadingStateEndingSystem extends System
	{
		private var engineStateMachine : EngineStateMachine;

		private var countdownNodeList : NodeList;
		private var moveNodeList : NodeList;

		public function CascadingStateEndingSystem(engineStateMachine : EngineStateMachine)
		{
			this.engineStateMachine = engineStateMachine;
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
				engineStateMachine.changeState("matching");
			}
		}

		private function hasBoardSettled() : Boolean
		{
			return areAllMoveNodesStill() &&
					noCountdowNodesAreActive();
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

		private function noCountdowNodesAreActive() : Boolean
		{
			return countdownNodeList.head == null;
		}
	}
}