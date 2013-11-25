package drop.board
{
	import flash.geom.Point;

	public class Match
	{
		public var positions : Vector.<Point>;
		private var tileSize : int;

		public var width : int;
		public var height : int;

		public function Match(positions : Vector.<Point>, tileSize : int)
		{
			this.positions = positions;
			this.tileSize = tileSize;

			width = calculateWidth();
			height = calculateHeight();
		}

		private function calculateWidth() : uint
		{
			var leftMostPositionX : Number = Number.MAX_VALUE;
			var rightMostPositionX : Number = 0;
			for each (var position : Point in positions)
			{
				leftMostPositionX = Math.min(leftMostPositionX, position.x);
				rightMostPositionX = Math.max(rightMostPositionX, position.x);
			}
			return rightMostPositionX - leftMostPositionX + tileSize;
		}

		private function calculateHeight() : uint
		{
			var topMostPositionY : Number = Number.MAX_VALUE;
			var bottomMostPositionY : Number = 0;
			for each (var position : Point in positions)
			{
				var positionY : Number = position.y;
				topMostPositionY = Math.min(topMostPositionY, positionY);
				bottomMostPositionY = Math.max(bottomMostPositionY, positionY);
			}
			return bottomMostPositionY - topMostPositionY + 70;
		}
	}
}
