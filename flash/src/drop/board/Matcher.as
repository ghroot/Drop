package drop.board
{
	public class Matcher
	{
		private static const MINIMUM_LINE_LENGTH : uint = 3;

		public function Matcher()
		{
		}

//		public function getMatches(letterNodes : Vector.<LetterNode>, boardSize : Point, tileSize : int) : Vector.<Match>
//		{
//			var matches : Vector.<Match> = new Vector.<Match>();
//			for each (var letterNode : LetterNode in letterNodes.slice())
//			{
//				var match : Match = getMatch(letterNode, letterNodes, boardSize, tileSize);
//				if (match != null)
//				{
//					var matchThatSharesLetterNode : Match = getMatchThatSharesLetterNode(match, matches);
//					if (matchThatSharesLetterNode != null)
//					{
//						if (match.getLetterNodes().length > matchThatSharesLetterNode.getLetterNodes().length)
//						{
//							matches.splice(matches.indexOf(matchThatSharesLetterNode), 1);
//							matches.push(match);
//						}
//					}
//					else
//					{
//						matches.push(match);
//					}
//				}
//			}
//			return matches;
//		}
//
//		public function hasMatches(letterNodes : Vector.<LetterNode>, boardSize : Point, tileSize : int) : Boolean
//		{
//			return getMatches(letterNodes, boardSize, tileSize).length > 0;
//		}
//
//		private function getMatchThatSharesLetterNode(match : Match, matches : Vector.<Match>) : Match
//		{
//			for each (var match2 : Match in matches)
//			{
//				for each (var letterNode1 : LetterNode in match.getLetterNodes())
//				{
//					for each (var letterNode2 : LetterNode in match2.getLetterNodes())
//					{
//						if (letterNode1.referencesSameEntityAs(letterNode2))
//						{
//							return match2;
//						}
//					}
//				}
//			}
//			return null;
//		}
//
//		public function getMatch(letterNode : LetterNode, letterNodes : Vector.<LetterNode>, boardSize : Point, tileSize : int) : Match
//		{
//			var matchedLetterNodes : Vector.<LetterNode> = new Vector.<LetterNode>();
//			matchedLetterNodes.push(letterNode);
//
//			var letterNodesInHorizontalMatch: Vector.<LetterNode> = getHorizontalMatchingItems(letterNode, letterNodes, boardSize, tileSize);
//			if (letterNodesInHorizontalMatch.length > 0)
//			{
//				matchedLetterNodes = matchedLetterNodes.concat(letterNodesInHorizontalMatch);
//			}
//
//			var letterNodesInVerticalMatch : Vector.<LetterNode> = getVerticalMatchingItems(letterNode, letterNodes, boardSize, tileSize);
//			if (letterNodesInVerticalMatch.length > 0)
//			{
//				matchedLetterNodes = matchedLetterNodes.concat(letterNodesInVerticalMatch);
//			}
//
//			if (matchedLetterNodes.length >= MINIMUM_LINE_LENGTH)
//			{
//				return new Match(matchedLetterNodes);
//			}
//			else
//			{
//				return null;
//			}
//		}
//
//		private function getHorizontalMatchingItems(letterNode : LetterNode, letterNodes : Vector.<LetterNode>, boardSize : Point, tileSize : int) : Vector.<LetterNode>
//		{
//			var letterNodesInHorizontalMatch : Vector.<LetterNode> = new Vector.<LetterNode>();
//			var currentX : Number = letterNode.transformComponent.position.x - tileSize;
//			while (currentX >= 0)
//			{
//				var letterNodeAtPosition : LetterNode = getLetterNodeAtPosition(letterNodes, new Point(currentX, letterNode.transformComponent.position.y));
//				if (letterNodeAtPosition != null &&
//						letterNodeAtPosition.letterComponent.letter == letterNode.letterComponent.letter)
//				{
//					letterNodesInHorizontalMatch.push(letterNodeAtPosition);
//					currentX -= tileSize;
//				}
//				else
//				{
//					break;
//				}
//			}
//			currentX = letterNode.transformComponent.position.x + tileSize;
//			while (currentX < boardSize.x * tileSize)
//			{
//				letterNodeAtPosition = getLetterNodeAtPosition(letterNodes, new Point(currentX, letterNode.transformComponent.position.y));
//				if (letterNodeAtPosition != null &&
//						letterNodeAtPosition.letterComponent.letter == letterNode.letterComponent.letter)
//				{
//					letterNodesInHorizontalMatch.push(letterNodeAtPosition);
//					currentX += tileSize;
//				}
//				else
//				{
//					break;
//				}
//			}
//
//			if (letterNodesInHorizontalMatch.length < (MINIMUM_LINE_LENGTH - 1))
//			{
//				letterNodesInHorizontalMatch.length = 0;
//			}
//
//			return letterNodesInHorizontalMatch;
//		}
//
//		private function getVerticalMatchingItems(letterNode : LetterNode, letterNodes : Vector.<LetterNode>, boardSize : Point, tileSize : int) : Vector.<LetterNode>
//		{
//			var letterNodesInVerticalMatch : Vector.<LetterNode> = new Vector.<LetterNode>();
//			var currentY : Number = letterNode.transformComponent.position.y - tileSize;
//			while (currentY >= 0)
//			{
//				var letterNodeAtPosition : LetterNode = getLetterNodeAtPosition(letterNodes, new Point(letterNode.transformComponent.position.x, currentY));
//				if (letterNodeAtPosition != null &&
//						letterNodeAtPosition.letterComponent.letter == letterNode.letterComponent.letter)
//				{
//					letterNodesInVerticalMatch.push(letterNodeAtPosition);
//					currentY -= tileSize;
//				}
//				else
//				{
//					break;
//				}
//			}
//			currentY = letterNode.transformComponent.position.y + tileSize;
//			while (currentY < boardSize.y * tileSize)
//			{
//				letterNodeAtPosition = getLetterNodeAtPosition(letterNodes, new Point(letterNode.transformComponent.position.x, currentY));
//				if (letterNodeAtPosition != null &&
//						letterNodeAtPosition.letterComponent.letter == letterNode.letterComponent.letter)
//				{
//					letterNodesInVerticalMatch.push(letterNodeAtPosition);
//					currentY += tileSize;
//				}
//				else
//				{
//					break;
//				}
//			}
//
//			if (letterNodesInVerticalMatch.length < (MINIMUM_LINE_LENGTH - 1))
//			{
//				letterNodesInVerticalMatch.length = 0;
//			}
//
//			return letterNodesInVerticalMatch;
//		}
//
//		private function getLetterNodeAtPosition(letterNodes : Vector.<LetterNode>, position : Point) : LetterNode
//		{
//			for each (var letterNode : LetterNode in letterNodes)
//			{
//				if (letterNode.transformComponent.position.equals(position))
//				{
//					return letterNode;
//				}
//			}
//			return null;
//		}
	}
}
