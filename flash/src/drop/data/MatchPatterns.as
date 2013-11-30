package drop.data
{
	import drop.board.Match;

	public class MatchPatterns
	{
		public static const NONE : int = 0;
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
			else if (match.width == 5 || match.height == 5)
			{
				return FIVE_OR_MORE_IN_A_ROW;
			}
			else if (match.width >= 3 && match.height >= 3)
			{
				return T_OR_L;
			}
			else
			{
				return NONE;
			}
		}

		public static function getName(pattern : int) : String
		{
			switch (pattern)
			{
				case MatchPatterns.THREE_IN_A_ROW:
					return "Three in a row";
				case MatchPatterns.FOUR_IN_A_ROW:
					return "Four in a row";
				case MatchPatterns.T_OR_L:
					return "T or L";
				case MatchPatterns.FIVE_OR_MORE_IN_A_ROW:
					return "Five in a row";
				default:
					return "";
			}
		}
	}
}
