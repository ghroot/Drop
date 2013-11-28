package drop.data
{
	import drop.board.Match;

	public class MatchPatterns
	{
		public static const THREE_IN_A_ROW : int = 1;
		public static const FOUR_IN_A_ROW : int = 2;
		public static const T_OR_L : int = 3;
		public static const FIVE_OR_MORE_IN_A_ROW : int = 4;

		public static function getFromMatch(match : Match) : int
		{
			if (match.matchNodes.length == 3)
			{
				return THREE_IN_A_ROW;
			}
			else if (match.matchNodes.length == 4)
			{
				return FOUR_IN_A_ROW;
			}
			else if (match.width == 1 || match.height == 1)
			{
				return FIVE_OR_MORE_IN_A_ROW;
			}
			else
			{
				return T_OR_L;
			}
		}
	}
}
