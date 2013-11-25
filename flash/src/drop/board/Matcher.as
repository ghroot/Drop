package drop.board
{
	import drop.node.MatchNode;

	import flash.geom.Point;

	public class Matcher
	{
		private static const MINIMUM_LINE_LENGTH : uint = 3;

		private var boardSize : Point;
		private var tileSize : int;

		private var reusableMatchedMatchNodes : Vector.<MatchNode>;
		private var reusableHorizontalOrVerticalMatchingNodes : Vector.<MatchNode>;

		public function Matcher(boardSize : Point, tileSize : int)
		{
			this.boardSize = boardSize;
			this.tileSize = tileSize;

			reusableMatchedMatchNodes = new Vector.<MatchNode>();
			reusableHorizontalOrVerticalMatchingNodes = new Vector.<MatchNode>();
		}

		public function getMatches(matchNodes : Vector.<MatchNode>) : Vector.<Match>
		{
			var matches : Vector.<Match> = new Vector.<Match>();
			for each (var matchNode : MatchNode in matchNodes)
			{
				var match : Match = getMatch(matchNode, matchNodes);
				if (match != null)
				{
					var matchThatSharesMatchNode : Match = getMatchThatSharesMatchNode(match, matches);
					if (matchThatSharesMatchNode != null)
					{
						if (match.matchNodes.length > matchThatSharesMatchNode.matchNodes.length)
						{
							matches.splice(matches.indexOf(matchThatSharesMatchNode), 1);
							matches[matches.length] = match;
						}
					}
					else
					{
						matches[matches.length] = match;
					}
				}
			}
			return matches;
		}

		public function hasMatches(matchNodes : Vector.<MatchNode>) : Boolean
		{
			return getMatches(matchNodes).length > 0;
		}

		private function getMatchThatSharesMatchNode(match : Match, matches : Vector.<Match>) : Match
		{
			for each (var otherMatch : Match in matches)
			{
				for each (var matchNodeInMatch : MatchNode in match.matchNodes)
				{
					for each (var matchNodeInOtherMatch : MatchNode in otherMatch.matchNodes)
					{
						if (matchNodeInMatch.entity == matchNodeInOtherMatch.entity)
						{
							return otherMatch;
						}
					}
				}
			}
			return null;
		}

		public function getMatch(matchNode : MatchNode, matchNodes : Vector.<MatchNode>) : Match
		{
			reusableMatchedMatchNodes.length = 0;

			reusableMatchedMatchNodes.push(matchNode);

			var matchNodesInHorizontalMatch : Vector.<MatchNode> = getHorizontalMatchingNodes(matchNode, matchNodes);
			for each (var matchNodeInHorizontalMatch : MatchNode in matchNodesInHorizontalMatch)
			{
				reusableMatchedMatchNodes[reusableMatchedMatchNodes.length] = matchNodeInHorizontalMatch;
			}

			var matchNodesInVerticalMatch : Vector.<MatchNode> = getVerticalMatchingNodes(matchNode, matchNodes);
			for each (var matchNodeInVerticalMatch : MatchNode in matchNodesInVerticalMatch)
			{
				reusableMatchedMatchNodes[reusableMatchedMatchNodes.length] = matchNodeInVerticalMatch;
			}

			if (reusableMatchedMatchNodes.length >= MINIMUM_LINE_LENGTH)
			{
				return new Match(reusableMatchedMatchNodes.slice(), tileSize);
			}
			else
			{
				return null;
			}
		}

		private function getHorizontalMatchingNodes(matchNode : MatchNode, matchNodes : Vector.<MatchNode>) : Vector.<MatchNode>
		{
			reusableHorizontalOrVerticalMatchingNodes.length = 0;

			var currentX : Number = matchNode.transformComponent.x - tileSize;
			while (currentX >= 0)
			{
				var matchNodeAtPosition : MatchNode = getMatchNodeAtPosition(matchNodes, currentX, matchNode.transformComponent.y);
				if (matchNodeAtPosition != null &&
						matchNodeAtPosition.matchComponent.color == matchNode.matchComponent.color)
				{
					reusableHorizontalOrVerticalMatchingNodes[reusableHorizontalOrVerticalMatchingNodes.length] = matchNodeAtPosition;
					currentX -= tileSize;
				}
				else
				{
					break;
				}
			}
			currentX = matchNode.transformComponent.x + tileSize;
			while (currentX < boardSize.x * tileSize)
			{
				matchNodeAtPosition = getMatchNodeAtPosition(matchNodes, currentX, matchNode.transformComponent.y);
				if (matchNodeAtPosition != null &&
						matchNodeAtPosition.matchComponent.color == matchNode.matchComponent.color)
				{
					reusableHorizontalOrVerticalMatchingNodes[reusableHorizontalOrVerticalMatchingNodes.length] = matchNodeAtPosition;
					currentX += tileSize;
				}
				else
				{
					break;
				}
			}

			if (reusableHorizontalOrVerticalMatchingNodes.length < MINIMUM_LINE_LENGTH - 1)
			{
				reusableHorizontalOrVerticalMatchingNodes.length = 0;
			}

			return reusableHorizontalOrVerticalMatchingNodes;
		}

		private function getVerticalMatchingNodes(matchNode : MatchNode, matchNodes : Vector.<MatchNode>) : Vector.<MatchNode>
		{
			reusableHorizontalOrVerticalMatchingNodes.length = 0;

			var currentY : Number = matchNode.transformComponent.y - tileSize;
			while (currentY >= 0)
			{
				var matchNodeAtPosition : MatchNode = getMatchNodeAtPosition(matchNodes, matchNode.transformComponent.x, currentY);
				if (matchNodeAtPosition != null &&
						matchNodeAtPosition.matchComponent.color == matchNode.matchComponent.color)
				{
					reusableHorizontalOrVerticalMatchingNodes[reusableHorizontalOrVerticalMatchingNodes.length] = matchNodeAtPosition;
					currentY -= tileSize;
				}
				else
				{
					break;
				}
			}
			currentY = matchNode.transformComponent.y + tileSize;
			while (currentY < boardSize.y * tileSize)
			{
				matchNodeAtPosition = getMatchNodeAtPosition(matchNodes, matchNode.transformComponent.x, currentY);
				if (matchNodeAtPosition != null &&
						matchNodeAtPosition.matchComponent.color == matchNode.matchComponent.color)
				{
					reusableHorizontalOrVerticalMatchingNodes[reusableHorizontalOrVerticalMatchingNodes.length] = matchNodeAtPosition;
					currentY += tileSize;
				}
				else
				{
					break;
				}
			}

			if (reusableHorizontalOrVerticalMatchingNodes.length < MINIMUM_LINE_LENGTH - 1)
			{
				reusableHorizontalOrVerticalMatchingNodes.length = 0;
			}

			return reusableHorizontalOrVerticalMatchingNodes;
		}

		private function getMatchNodeAtPosition(matchNodes : Vector.<MatchNode>, positionX : Number, positionY : Number) : MatchNode
		{
			for each (var matchNode : MatchNode in matchNodes)
			{
				if (matchNode.transformComponent.x == positionX &&
						matchNode.transformComponent.y == positionY)
				{
					return matchNode;
				}
			}
			return null;
		}
	}
}
