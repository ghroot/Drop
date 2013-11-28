package drop.data
{
	import flash.utils.Dictionary;

	public class GameState
	{
		public var inputs : Vector.<Input>;

		public var credits : int;
		public var pendingCredits : int;

		public var shouldStartSwap : Boolean;
		public var swapInProgress : Boolean;
		public var isTryingSwap : Boolean;
		public var isSwappingBack : Boolean;

		public var atLeastOneMatch : Boolean;

		public var matchPatternLevels : Dictionary;

		public function GameState()
		{
			inputs = new Vector.<Input>();
			matchPatternLevels = new Dictionary();
			matchPatternLevels[MatchPatterns.THREE_IN_A_ROW] = new MatchPatternLevel(Vector.<int>([0, 10, 50, 200, 500]));
			matchPatternLevels[MatchPatterns.FOUR_IN_A_ROW] = new MatchPatternLevel(Vector.<int>([0, 3, 10, 30, 100]));
			matchPatternLevels[MatchPatterns.T_OR_L] = new MatchPatternLevel(Vector.<int>([0, 3, 10, 30, 100]));
			matchPatternLevels[MatchPatterns.FIVE_OR_MORE_IN_A_ROW] = new MatchPatternLevel(Vector.<int>([0, 2, 5, 10, 30]));
		}
	}
}