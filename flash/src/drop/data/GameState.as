package drop.data
{
	import flash.utils.Dictionary;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	public class GameState
	{
		public var creditsUpdated : ISignal;
		public var pendingCreditsUpdated : ISignal;
		public var matchPatternLevelUpdated : ISignal;

		public var inputs : Vector.<Input>;

		public var credits : int;
		public var pendingCredits : int;

		public var shouldStartSwap : Boolean;
		public var swapInProgress : Boolean;
		public var isTryingSwap : Boolean;
		public var isSwappingBack : Boolean;

		public var matchInfos : Vector.<MatchInfo>;
		public var totalNumberOfMatchesDuringCascading : int;
		public var totalNumberOfLineBlastsDuringCascading : int;

		public var matchPatternLevels : Dictionary;

		public function GameState()
		{
			creditsUpdated = new Signal(int);
			pendingCreditsUpdated = new Signal(int);
			matchPatternLevelUpdated = new Signal(MatchPatternLevel);

			inputs = new Vector.<Input>();
			matchInfos = new Vector.<MatchInfo>();
			matchPatternLevels = new Dictionary();
			matchPatternLevels[MatchPatterns.THREE_IN_A_ROW] = new MatchPatternLevel(MatchPatterns.THREE_IN_A_ROW, Vector.<int>([0, 0, 10, 50, 200, 500]));
			matchPatternLevels[MatchPatterns.FOUR_IN_A_ROW] = new MatchPatternLevel(MatchPatterns.FOUR_IN_A_ROW, Vector.<int>([0, 0, 3, 10, 30, 100]));
			matchPatternLevels[MatchPatterns.T_OR_L] = new MatchPatternLevel(MatchPatterns.T_OR_L, Vector.<int>([0, 0, 3, 10, 30, 100]));
			matchPatternLevels[MatchPatterns.FIVE_OR_MORE_IN_A_ROW] = new MatchPatternLevel(MatchPatterns.FIVE_OR_MORE_IN_A_ROW, Vector.<int>([0, 0, 2, 5, 10, 30]));
		}
	}
}