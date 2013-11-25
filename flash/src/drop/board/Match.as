package drop.board
{
	import drop.node.MatchNode;

	public class Match
	{
		public var matchNodes : Vector.<MatchNode>;
		private var tileSize : int;

		public var width : int;
		public var height : int;

		public function Match(matchNodes : Vector.<MatchNode>, tileSize : int)
		{
			this.matchNodes = matchNodes;
			this.tileSize = tileSize;

			width = calculateWidth();
			height = calculateHeight();
		}

		private function calculateWidth() : uint
		{
			var leftMostPositionX : Number = Number.MAX_VALUE;
			var rightMostPositionX : Number = 0;
			for each (var matchNode : MatchNode in matchNodes)
			{
				leftMostPositionX = min(leftMostPositionX, matchNode.transformComponent.x);
				rightMostPositionX = max(rightMostPositionX, matchNode.transformComponent.x);
			}
			return rightMostPositionX - leftMostPositionX + tileSize;
		}

		private function calculateHeight() : uint
		{
			var topMostPositionY : Number = Number.MAX_VALUE;
			var bottomMostPositionY : Number = 0;
			for each (var matchNode : MatchNode in matchNodes)
			{
				topMostPositionY = min(topMostPositionY, matchNode.transformComponent.y);
				bottomMostPositionY = max(bottomMostPositionY, matchNode.transformComponent.y);
			}
			return bottomMostPositionY - topMostPositionY + 70;
		}

		private function min(number1 : Number, number2 : Number) : Number
		{
			return number1 < number2 ? number1 : number2;
		}

		private function max(number1 : Number, number2 : Number) : Number
		{
			return number1 > number2 ? number1 : number2;
		}
	}
}
