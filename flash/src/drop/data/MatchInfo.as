package drop.data
{
	import flash.geom.Point;

	public class MatchInfo
	{
		public var pattern : int;
		public var positions : Vector.<Point>;

		public function MatchInfo(pattern : int, positions : Vector.<Point>)
		{
			this.pattern = pattern;
			this.positions = positions;
		}
	}
}
