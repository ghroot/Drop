package drop.system
{
	import ash.core.Engine;
	import ash.core.NodeList;
	import ash.core.System;
	import ash.fsm.EngineStateMachine;

	import drop.board.EntityManager;
	import drop.board.Matcher;
	import drop.node.MatchNode;

	public class TurnEndStateEndingSystem extends System
	{
		private var stateMachine : EngineStateMachine;
		private var matcher : Matcher;
		private var entityManager : EntityManager;

		private var matchNodeList : NodeList;

		public function TurnEndStateEndingSystem(stateMachine : EngineStateMachine, matcher : Matcher, entityManager : EntityManager)
		{
			this.stateMachine = stateMachine;
			this.matcher = matcher;
			this.entityManager = entityManager;
		}

		override public function addToEngine(engine : Engine) : void
		{
			matchNodeList = engine.getNodeList(MatchNode);
		}

		override public function update(time : Number) : void
		{
			if (matcher.hasPossibleMatches(matchNodeList))
			{
				stateMachine.changeState("selecting");
			}
			else
			{
				for (var matchNode : MatchNode = matchNodeList.head; matchNode; matchNode = matchNode.next)
				{
					entityManager.destroyEntity(matchNode.entity);
				}

				stateMachine.changeState("cascading");
			}
		}
	}
}
