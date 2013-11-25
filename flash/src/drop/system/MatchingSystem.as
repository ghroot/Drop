package drop.system
{
	import ash.core.Engine;
	import ash.core.NodeList;
	import ash.core.System;

	import drop.board.Match;
	import drop.board.Matcher;
	import drop.data.GameState;
	import drop.node.MatchNode;

	public class MatchingSystem extends System
	{
		private var matcher : Matcher;
		private var gameState : GameState;

		private var matchNodeList : NodeList;
		private var matchNodes : Vector.<MatchNode>;

		public function MatchingSystem(matcher : Matcher, gameState : GameState)
		{
			this.matcher = matcher;
			this.gameState = gameState;

			matchNodes = new Vector.<MatchNode>();
		}

		override public function addToEngine(engine : Engine) : void
		{
			matchNodeList = engine.getNodeList(MatchNode);
		}

		override public function update(time : Number) : void
		{
			matchNodes.length = 0;
			for (var matchNode : MatchNode = matchNodeList.head; matchNode; matchNode = matchNode.next)
			{
				matchNodes[matchNodes.length] = matchNode;
			}

			var matches : Vector.<Match> = matcher.getMatches(matchNodes);
			for each (var match : Match in matches)
			{
				for each (matchNode in match.matchNodes)
				{
					matchNode.stateComponent.stateMachine.changeState("matched");
				}

				var creditsToAdd : int = match.matchNodes.length;
				if (match.matchNodes.length >= 5)
				{
					creditsToAdd *= 3;
				}
				else if (match.matchNodes.length >= 4)
				{
					creditsToAdd *= 2;
				}
				gameState.credits += creditsToAdd;
			}

			gameState.atLeastOneMatch = matches.length > 0;
		}
	}
}
