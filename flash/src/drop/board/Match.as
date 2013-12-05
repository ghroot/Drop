package drop.board
{
	import drop.node.MatchNode;
	import drop.util.MathUtils;

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
				leftMostPositionX = MathUtils.min(leftMostPositionX, matchNode.transformComponent.x);
				rightMostPositionX = MathUtils.max(rightMostPositionX, matchNode.transformComponent.x);
			}
			return (rightMostPositionX - leftMostPositionX + tileSize) / tileSize;
		}

		private function calculateHeight() : uint
		{
			var topMostPositionY : Number = Number.MAX_VALUE;
			var bottomMostPositionY : Number = 0;
			for each (var matchNode : MatchNode in matchNodes)
			{
				topMostPositionY = MathUtils.min(topMostPositionY, matchNode.transformComponent.y);
				bottomMostPositionY = MathUtils.max(bottomMostPositionY, matchNode.transformComponent.y);
			}
			return (bottomMostPositionY - topMostPositionY + tileSize) / tileSize;
		}
	}
}
