package drop.data
{
	public class MatchPatternLevel
	{
		private var requiredPointsPerLevel : Vector.<int>;

		public var points : int;

		public function MatchPatternLevel(requiredPointsPerLevel : Vector.<int>)
		{
			this.requiredPointsPerLevel = requiredPointsPerLevel;
		}

		public function getLevel() : int
		{
			for (var i : int = requiredPointsPerLevel.length - 1; i >= 0; i--)
			{
				if (points >= requiredPointsPerLevel[i])
				{
					return i;
				}
			}
			return 0;
		}
	}
}
