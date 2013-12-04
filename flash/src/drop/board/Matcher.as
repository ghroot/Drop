package drop.board
{
	import ash.core.NodeList;

	import drop.node.MatchNode;

	import flash.geom.Point;
	import flash.utils.Dictionary;

	public class Matcher
	{
		private static const MINIMUM_LINE_LENGTH : uint = 3;

		private var boardSize : Point;
		private var tileSize : int;

		private var matchNodesByPosition : Dictionary;
		private var reusableMatchedMatchNodes : Vector.<MatchNode>;
		private var reusableHorizontalOrVerticalMatchingNodes : Vector.<MatchNode>;

		public function Matcher(boardSize : Point, tileSize : int)
		{
			this.boardSize = boardSize;
			this.tileSize = tileSize;

			reusableMatchedMatchNodes = new Vector.<MatchNode>();
			reusableHorizontalOrVerticalMatchingNodes = new Vector.<MatchNode>();
		}

		public function getMatches(matchNodeList : NodeList) : Vector.<Match>
		{
			updateMatchNodesByPosition(matchNodeList);

			var matches : Vector.<Match> = new Vector.<Match>();
			for (var matchNode : MatchNode = matchNodeList.head; matchNode; matchNode = matchNode.next)
			{
				var match : Match = getMatch(matchNode);
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

		private function getMatch(matchNode : MatchNode) : Match
		{
			reusableMatchedMatchNodes.length = 0;

			reusableMatchedMatchNodes.push(matchNode);

			var matchNodesInHorizontalMatch : Vector.<MatchNode> = getHorizontalMatchingNodes(matchNode);
			for each (var matchNodeInHorizontalMatch : MatchNode in matchNodesInHorizontalMatch)
			{
				reusableMatchedMatchNodes[reusableMatchedMatchNodes.length] = matchNodeInHorizontalMatch;
			}

			var matchNodesInVerticalMatch : Vector.<MatchNode> = getVerticalMatchingNodes(matchNode);
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

		private function getHorizontalMatchingNodes(matchNode : MatchNode) : Vector.<MatchNode>
		{
			reusableHorizontalOrVerticalMatchingNodes.length = 0;

			var currentX : Number = matchNode.transformComponent.x - tileSize;
			while (currentX >= 0)
			{
				var matchNodeAtPosition : MatchNode = getMatchNodeAtPosition(currentX, matchNode.transformComponent.y);
				if (matchNodeAtPosition != null &&
						matchNodeAtPosition.matchComponent.type == matchNode.matchComponent.type)
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
				matchNodeAtPosition = getMatchNodeAtPosition(currentX, matchNode.transformComponent.y);
				if (matchNodeAtPosition != null &&
						matchNodeAtPosition.matchComponent.type == matchNode.matchComponent.type)
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

		private function getVerticalMatchingNodes(matchNode : MatchNode) : Vector.<MatchNode>
		{
			reusableHorizontalOrVerticalMatchingNodes.length = 0;

			var currentY : Number = matchNode.transformComponent.y - tileSize;
			while (currentY >= 0)
			{
				var matchNodeAtPosition : MatchNode = getMatchNodeAtPosition(matchNode.transformComponent.x, currentY);
				if (matchNodeAtPosition != null &&
						matchNodeAtPosition.matchComponent.type == matchNode.matchComponent.type)
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
				matchNodeAtPosition = getMatchNodeAtPosition(matchNode.transformComponent.x, currentY);
				if (matchNodeAtPosition != null &&
						matchNodeAtPosition.matchComponent.type == matchNode.matchComponent.type)
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

		private function updateMatchNodesByPosition(matchNodeList : NodeList) : void
		{
			matchNodesByPosition = new Dictionary();
			for (var matchNode : MatchNode = matchNodeList.head; matchNode; matchNode = matchNode.next)
			{
				matchNodesByPosition[getKey(matchNode.transformComponent.x, matchNode.transformComponent.y)] = matchNode;
			}
		}

		private function getMatchNodeAtPosition(positionX : Number, positionY : Number) : MatchNode
		{
			return matchNodesByPosition[getKey(positionX, positionY)];
		}

		private function getKey(positionX : Number, positionY : Number) : int
		{
			return positionY * boardSize.x + positionX;
		}
	}
}
