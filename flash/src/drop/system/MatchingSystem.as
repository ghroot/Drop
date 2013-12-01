package drop.system
{
	import ash.core.Engine;
	import ash.core.NodeList;
	import ash.core.System;

	import drop.board.Match;
	import drop.board.Matcher;
	import drop.data.GameRules;
	import drop.data.GameState;
	import drop.data.MatchInfo;
	import drop.data.MatchPatternLevel;
	import drop.data.MatchPatterns;
	import drop.node.MatchNode;

	import flash.geom.Point;

	public class MatchingSystem extends System
	{
		private var matcher : Matcher;
		private var gameState : GameState;
		private var gameRules : GameRules;

		private var matchNodeList : NodeList;

		public function MatchingSystem(matcher : Matcher, gameState : GameState, gameRules : GameRules)
		{
			this.matcher = matcher;
			this.gameState = gameState;
			this.gameRules = gameRules;
		}

		override public function addToEngine(engine : Engine) : void
		{
			matchNodeList = engine.getNodeList(MatchNode);
		}

		override public function update(time : Number) : void
		{
			gameState.matchInfos.length = 0;
			gameState.matchInfoToHighlight = null;

			var matches : Vector.<Match> = matcher.getMatches(matchNodeList);
			for each (var match : Match in matches)
			{
				for each (var matchNode : MatchNode in match.matchNodes)
				{
					matchNode.stateComponent.stateMachine.changeState("matched");
				}

				var pattern : int = MatchPatterns.getFromMatch(match);
				var matchPatternLevel : MatchPatternLevel = gameState.matchPatternLevels[pattern];

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
				gameRules.addPendingCredits(creditsToAdd);

				var matchInfo : MatchInfo = createMatchInfo(pattern, match);

				var level : int = matchPatternLevel.getLevel();
				matchPatternLevel.points++;
				if (matchPatternLevel.getLevel() > level)
				{
					// TODO: Handle several match infos to highlight
					gameState.matchInfoToHighlight = matchInfo;
				}

				gameState.matchInfos[gameState.matchInfos.length] = matchInfo;
			}

			gameState.totalNumberOfMatchesDuringCascading += matches.length;
		}

		private function createMatchInfo(pattern : int, match : Match) : MatchInfo
		{
			var positions : Vector.<Point> = new Vector.<Point>();
			for each (var matchNode : MatchNode in match.matchNodes)
			{
				positions[positions.length] = new Point(matchNode.transformComponent.x, matchNode.transformComponent.y);
			}
			return new MatchInfo(pattern, positions);
		}
	}
}
