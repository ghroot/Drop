package drop.data
{
	import drop.util.EndlessValueSequence;

	public class MatchPatternLevel
	{
		public var pattern : int;
		private var requiredPoints : EndlessValueSequence;
		private var creditYields : EndlessValueSequence;

		public var points : int;

		public function MatchPatternLevel(pattern : int, requiredPoints : EndlessValueSequence, creditYields : EndlessValueSequence)
		{
			this.pattern = pattern;
			this.requiredPoints = requiredPoints;
			this.creditYields = creditYields;
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

		public function getCreditYield() : int
		{
			return creditYields.getValue(getLevel());
		}
	}
}
