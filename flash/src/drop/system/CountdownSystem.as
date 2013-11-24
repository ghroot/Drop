package drop.system
{
	import ash.core.*;

	import drop.EntityManager;
	import drop.data.Countdown;
	import drop.node.CountdownNode;

	public class CountdownSystem extends System
	{
		private var entityManager : EntityManager;
		private var countdownNodeList : NodeList;

		public function CountdownSystem(entityManager : EntityManager)
		{
			this.entityManager = entityManager;
		}

		override public function addToEngine(engine : Engine) : void
		{
			countdownNodeList = engine.getNodeList(CountdownNode);
			countdownNodeList.nodeAdded.add(onNodeAdded);

			for (var countdownNode : CountdownNode = countdownNodeList.head as CountdownNode; countdownNode; countdownNode = countdownNode.next as CountdownNode)
			{
				resetCountdown(countdownNode);
			}
		}

		override public function removeFromEngine(engine : Engine) : void
		{
			countdownNodeList.nodeAdded.remove(onNodeAdded);
		}

		private function onNodeAdded(node : Node) : void
		{
			resetCountdown(node as CountdownNode);
		}

		private function resetCountdown(countdownNode : CountdownNode) : void
		{
			if (countdownNode.countdownComponent.countdown == null)
			{
				countdownNode.countdownComponent.countdown = new Countdown(countdownNode.countdownComponent.time);
			}
			else
			{
				countdownNode.countdownComponent.countdown.reset();
			}
		}

		override public function update(time : Number) : void
		{
			for (var countdownNode : CountdownNode = countdownNodeList.head; countdownNode; countdownNode = countdownNode.next)
			{
				if (countdownNode.countdownComponent.countdown.countdownAndReturnIfReachedZero(time))
				{
					if (countdownNode.countdownComponent.stateToChangeTo != null)
					{
						countdownNode.stateComponent.stateMachine.changeState(countdownNode.countdownComponent.stateToChangeTo);
					}
					else
					{
						entityManager.destroyEntity(countdownNode.entity);
					}
				}
			}
		}
	}
}
