package drop.board
{
	import ash.core.NodeList;

	import drop.data.Axis;
	import drop.data.Directions;
	import drop.node.MatchNode;

	import flash.geom.Point;
	import flash.utils.Dictionary;

	public class Matcher
	{
		private static const MINIMUM_LINE_LENGTH : uint = 3;

		private var boardSize : Point;
		private var tileSize : int;

		private var offsetsForDirections : Vector.<Point>;

		private var matchNodesByPosition : Dictionary;
		private var reusableMatchedMatchNodes : Vector.<MatchNode>;
		private var reusableHorizontalOrVerticalMatchingNodes : Vector.<MatchNode>;

		public function Matcher(boardSize : Point, tileSize : int)
		{
			this.boardSize = boardSize;
			this.tileSize = tileSize;

			offsetsForDirections = new <Point>
			[
				new Point(0, 0),
				new Point(-tileSize, 0),
				new Point(-tileSize, -tileSize),
				new Point(0, -tileSize),
				new Point(tileSize, -tileSize),
				new Point(tileSize, 0),
				new Point(tileSize, tileSize),
				new Point(0, tileSize),
				new Point(-tileSize, tileSize)
			];

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

			var matchNodesInHorizontalMatch : Vector.<MatchNode> = getMatchingNodes(matchNode, Axis.HORIZONTAL);
			for each (var matchNodeInHorizontalMatch : MatchNode in matchNodesInHorizontalMatch)
			{
				reusableMatchedMatchNodes[reusableMatchedMatchNodes.length] = matchNodeInHorizontalMatch;
			}

			var matchNodesInVerticalMatch : Vector.<MatchNode> = getMatchingNodes(matchNode, Axis.VERTICAL);
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

		private function getMatchingNodes(matchNode : MatchNode, axis : int) : Vector.<MatchNode>
		{
			reusableHorizontalOrVerticalMatchingNodes.length = 0;

			var minPosition : Number = 0;
			var maxPosition : Number = (axis == Axis.HORIZONTAL ? boardSize.x : boardSize.y) * tileSize
			var currentPosition : Number = axis == Axis.HORIZONTAL ? matchNode.transformComponent.x - tileSize : matchNode.transformComponent.y - tileSize;
			while (currentPosition >= minPosition)
			{
				var matchNodeAtPosition : MatchNode = axis == Axis.HORIZONTAL ?
						getMatchNodeAtPosition(currentPosition, matchNode.transformComponent.y) :
						getMatchNodeAtPosition(matchNode.transformComponent.x, currentPosition);
				if (matchNodeAtPosition != null &&
						matchNodeAtPosition.matchComponent.type == matchNode.matchComponent.type)
				{
					reusableHorizontalOrVerticalMatchingNodes[reusableHorizontalOrVerticalMatchingNodes.length] = matchNodeAtPosition;
					currentPosition -= tileSize;
				}
				else
				{
					break;
				}
			}
			currentPosition = axis == Axis.HORIZONTAL ? matchNode.transformComponent.x + tileSize : matchNode.transformComponent.y + tileSize;
			while (currentPosition < maxPosition)
			{
				matchNodeAtPosition = axis == Axis.HORIZONTAL ?
						getMatchNodeAtPosition(currentPosition, matchNode.transformComponent.y) :
						getMatchNodeAtPosition(matchNode.transformComponent.x, currentPosition);
				if (matchNodeAtPosition != null &&
						matchNodeAtPosition.matchComponent.type == matchNode.matchComponent.type)
				{
					reusableHorizontalOrVerticalMatchingNodes[reusableHorizontalOrVerticalMatchingNodes.length] = matchNodeAtPosition;
					currentPosition += tileSize;
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

		public function hasPossibleMatches(matchNodeList : NodeList) : Boolean
		{
			updateMatchNodesByPosition(matchNodeList);

			for (var matchNode : MatchNode = matchNodeList.head; matchNode; matchNode = matchNode.next)
			{
				for each (var direction : int in Directions.STRAIGHT_DIRECTIONS)
				{
					var matchNodeInDirection : MatchNode = getMatchNodeAtPosition(matchNode.transformComponent.x + offsetsForDirections[direction].x, matchNode.transformComponent.y + offsetsForDirections[direction].y);
					if (matchNodeInDirection != null &&
							matchNodeInDirection.matchComponent.type == matchNode.matchComponent.type)
					{
						var positionX : Number = matchNode.transformComponent.x + 2 * offsetsForDirections[direction].x;
						var positionY : Number = matchNode.transformComponent.y + 2 * offsetsForDirections[direction].y;

						matchNodeInDirection = getMatchNodeAtPosition(positionX + offsetsForDirections[direction].x, positionY + offsetsForDirections[direction].y);
						if (matchNodeInDirection != null &&
								matchNodeInDirection.matchComponent.type == matchNode.matchComponent.type)
						{
							return true;
						}

						var otherDirection : int = Directions.getNextDirection(Directions.getNextDirection(direction));
						matchNodeInDirection = getMatchNodeAtPosition(positionX + offsetsForDirections[otherDirection].x, positionY + offsetsForDirections[otherDirection].y);
						if (matchNodeInDirection != null &&
								matchNodeInDirection.matchComponent.type == matchNode.matchComponent.type)
						{
							return true;
						}

						otherDirection = Directions.getPreviousDirection(Directions.getPreviousDirection(direction));
						matchNodeInDirection = getMatchNodeAtPosition(positionX + offsetsForDirections[otherDirection].x, positionY + offsetsForDirections[otherDirection].y);
						if (matchNodeInDirection != null &&
								matchNodeInDirection.matchComponent.type == matchNode.matchComponent.type)
						{
							return true;
						}
					}

					matchNodeInDirection = getMatchNodeAtPosition(matchNode.transformComponent.x + 2 * offsetsForDirections[direction].x, matchNode.transformComponent.y + 2 * offsetsForDirections[direction].y);
					if (matchNodeInDirection != null &&
							matchNodeInDirection.matchComponent.type == matchNode.matchComponent.type)
					{
						var diagonalDirection : int = Directions.getNextDirection(direction);
						matchNodeInDirection = getMatchNodeAtPosition(matchNode.transformComponent.x + offsetsForDirections[diagonalDirection].x, matchNode.transformComponent.y + offsetsForDirections[diagonalDirection].y);
						if (matchNodeInDirection != null &&
								matchNodeInDirection.matchComponent.type == matchNode.matchComponent.type)
						{
							return true;
						}

						diagonalDirection = Directions.getPreviousDirection(direction);
						matchNodeInDirection = getMatchNodeAtPosition(matchNode.transformComponent.x + offsetsForDirections[diagonalDirection].x, matchNode.transformComponent.y + offsetsForDirections[diagonalDirection].y);
						if (matchNodeInDirection != null &&
								matchNodeInDirection.matchComponent.type == matchNode.matchComponent.type)
						{
							return true;
						}
					}
				}
			}

			return false;
		}

		private function updateMatchNodesByPosition(matchNodeList : NodeList) : void
		{
			matchNodesByPosition = new Dictionary();
			for (var matchNode : MatchNode = matchNodeList.head; matchNode; matchNode = matchNode.next)
			{
				matchNodesByPosition[getKey(matchNode.transformComponent.x, matchNode.transformComponent.y)] = matchNode;
			}
		}

		[Inline]
		private final function getMatchNodeAtPosition(positionX : Number, positionY : Number) : MatchNode
		{
			return matchNodesByPosition[getKey(positionX, positionY)];
		}

		[Inline]
		private final function getKey(positionX : Number, positionY : Number) : int
		{
			return positionY * 100000 + positionX;
		}
	}
}
