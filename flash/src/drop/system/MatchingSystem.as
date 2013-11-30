package drop.system
{
	import ash.core.Engine;
	import ash.core.NodeList;
	import ash.core.System;

	import drop.board.Match;
	import drop.board.Matcher;
	import drop.data.GameState;
	import drop.data.MatchInfo;
	import drop.data.MatchPatternLevel;
	import drop.data.MatchPatterns;
	import drop.node.MatchNode;
	import drop.util.MathUtils;

	public class MatchingSystem extends System
	{
		private var matcher : Matcher;
		private var gameState : GameState;

		private var matchNodeList : NodeList;

		public function MatchingSystem(matcher : Matcher, gameState : GameState)
		{
			this.matcher = matcher;
			this.gameState = gameState;
		}

		override public function addToEngine(engine : Engine) : void
		{
			matchNodeList = engine.getNodeList(MatchNode);
		}

		override public function update(time : Number) : void
		{
			gameState.matchInfos.length = 0;

			var matches : Vector.<Match> = matcher.getMatches(matchNodeList);
			for each (var match : Match in matches)
			{
				for each (var matchNode : MatchNode in match.matchNodes)
				{
					matchNode.stateComponent.stateMachine.changeState("matched");
				}

				var matchPatternLevel : MatchPatternLevel = gameState.matchPatternLevels[MatchPatterns.getFromMatch(match)];

				var creditsToAdd : int = match.matchNodes.length;
				if (match.matchNodes.length >= 5)
				{
					creditsToAdd *= 3;
				}
				else if (match.matchNodes.length >= 4)
				{
					creditsToAdd *= 2;
				}
				creditsToAdd += matchPatternLevel.getNumberOfBonusCredits();
				gameState.addPendingCredits(creditsToAdd);

				var level : int = matchPatternLevel.getLevel();
				matchPatternLevel.points++;
				if (matchPatternLevel.getLevel() > level)
				{
					gameState.matchPatternLevelUpdated.dispatch(matchPatternLevel);
				}

				gameState.matchInfos[gameState.matchInfos.length] = createMatchInfo(match, creditsToAdd);
			}

			gameState.totalNumberOfMatchesDuringCascading += matches.length;
		}

		private function createMatchInfo(match : Match, credits : int) : MatchInfo
		{
			var leftMostPositionX : Number;
			var rightMostPositionX : Number;
			var topMostPositionY : Number;
			var bottomMostPositionY : Number;
			for each (var matchNode : MatchNode in match.matchNodes)
			{
				leftMostPositionX = MathUtils.min(leftMostPositionX, matchNode.transformComponent.x);
				rightMostPositionX = MathUtils.max(rightMostPositionX, matchNode.transformComponent.x);
				topMostPositionY = MathUtils.min(topMostPositionY, matchNode.transformComponent.y);
				bottomMostPositionY = MathUtils.max(bottomMostPositionY, matchNode.transformComponent.y);
			}
			return new MatchInfo(leftMostPositionX + (rightMostPositionX - leftMostPositionX) / 2,
					topMostPositionY + (bottomMostPositionY - topMostPositionY) / 2, credits);
		}
	}
}
