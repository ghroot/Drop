package drop.data
{
	public class MatchPatternLevel
	{
		public var pattern : int;
		private var requiredPointsPerLevel : Vector.<int>;

		public var points : int;

		public function MatchPatternLevel(pattern : int, requiredPointsPerLevel : Vector.<int>)
		{
			this.pattern = pattern;
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

		public function getNumberOfBonusCredits() : int
		{
			return (getLevel() - 1) * 3;
		}

		public function getRequiredPointsForNextLevel() : int
		{
			return requiredPointsPerLevel[getLevel() + 1];
		}

		public function getPercentTowardsNextLevel() : Number
		{
			return (points - requiredPointsPerLevel[getLevel()]) / (getRequiredPointsForNextLevel() - requiredPointsPerLevel[getLevel()]);
		}
	}
}
