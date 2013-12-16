package drop.data
{
	import drop.util.EndlessValueSequence;

	public class MatchPatternLevel
	{
		public var pattern : int;
		private var requiredPoints : EndlessValueSequence;

		public var points : int;

		public function MatchPatternLevel(pattern : int, requiredPoints : EndlessValueSequence)
		{
			this.pattern = pattern;
			this.requiredPoints = requiredPoints;
		}

		public function getLevel() : int
		{
			var level : int = 0;
			while (requiredPoints.getValue(level) < points)
			{
				level++;
			}
			return level;
		}

		public function getNumberOfBonusCredits() : int
		{
			return getLevel() * 3;
		}

		public function getRequiredPointsForNextLevel() : int
		{
			return requiredPoints.getValue(getLevel() + 1);
		}
	}
}
