package drop.system
{
	import ash.core.Engine;
	import ash.core.NodeList;
	import ash.core.System;

	import drop.board.Match;
	import drop.board.Matcher;
	import drop.data.MatchInfo;
	import drop.data.MatchPatternLevel;
	import drop.data.MatchPatterns;
	import drop.node.GameNode;
	import drop.node.MatchNode;

	import flash.geom.Point;

	public class MatchingSystem extends System
	{
		private var matcher : Matcher;

		private var gameNode : GameNode;
		private var matchNodeList : NodeList;

		public function MatchingSystem(matcher : Matcher)
		{
			this.matcher = matcher;
		}

		override public function addToEngine(engine : Engine) : void
		{
			gameNode = engine.getNodeList(GameNode).head;
			matchNodeList = engine.getNodeList(MatchNode);
		}

		override public function update(time : Number) : void
		{
			gameNode.gameStateComponent.matchInfos.length = 0;

			var matches : Vector.<Match> = matcher.getMatches(matchNodeList);
			for each (var match : Match in matches)
			{
				for each (var matchNode : MatchNode in match.matchNodes)
				{
					matchNode.stateComponent.stateMachine.changeState("matched");
				}

				var pattern : int = MatchPatterns.getFromMatch(match);
				var matchPatternLevel : MatchPatternLevel = gameNode.gameStateComponent.matchPatternLevels[pattern];

				var creditsToAdd : int = matchPatternLevel.getCreditYield();
				gameNode.gameStateComponent.pendingCredits += creditsToAdd;
				gameNode.gameStateComponent.pendingCreditsUpdated.dispatch();

				var matchInfo : MatchInfo = createMatchInfo(pattern, match);

				var level : int = matchPatternLevel.getLevel();
				matchPatternLevel.points++;
				if (matchPatternLevel.getLevel() > level)
				{
					gameNode.gameStateComponent.matchInfosToHighlight[gameNode.gameStateComponent.matchInfosToHighlight.length] = matchInfo;
				}

				gameNode.gameStateComponent.matchInfos[gameNode.gameStateComponent.matchInfos.length] = matchInfo;
			}

			gameNode.gameStateComponent.totalNumberOfMatchesDuringCascading += matches.length;
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
