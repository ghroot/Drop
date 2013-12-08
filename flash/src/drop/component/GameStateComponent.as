package drop.component
{
	import ash.tools.ComponentPool;

	import drop.data.*;

	import flash.utils.Dictionary;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	public class GameStateComponent
	{
		public var creditsUpdated : ISignal;
		public var pendingCreditsUpdated : ISignal;

		public var inputs : Vector.<Input>;

		public var credits : int;
		public var pendingCredits : int;

		public var shouldStartSwap : Boolean;
		public var swapInProgress : Boolean;
		public var isTryingSwap : Boolean;
		public var isSwappingBack : Boolean;

		public var matchInfos : Vector.<MatchInfo>;
		public var matchInfoToHighlight : MatchInfo;
		public var totalNumberOfMatchesDuringCascading : int;
		public var totalNumberOfLineBlastsDuringCascading : int;

		public var matchPatternLevels : Dictionary;
		public var isSelecting : Boolean;

		public function GameStateComponent()
		{
			creditsUpdated = new Signal();
			pendingCreditsUpdated = new Signal();
		}

		public static function create() : GameStateComponent
		{
			var component : GameStateComponent = ComponentPool.get(GameStateComponent);
			component.reset();
			return component;
		}

		public function reset() : void
		{
			inputs = new Vector.<Input>();
			matchInfos = new Vector.<MatchInfo>();
			matchPatternLevels = new Dictionary();
			matchPatternLevels[MatchPatterns.THREE_IN_A_ROW] = new MatchPatternLevel(MatchPatterns.THREE_IN_A_ROW, Vector.<int>([0, 0, 10, 30, 60, 100, 150]));
			matchPatternLevels[MatchPatterns.FOUR_IN_A_ROW] = new MatchPatternLevel(MatchPatterns.FOUR_IN_A_ROW, Vector.<int>([0, 0, 3, 8, 15, 30, 50]));
			matchPatternLevels[MatchPatterns.T_OR_L] = new MatchPatternLevel(MatchPatterns.T_OR_L, Vector.<int>([0, 0, 3, 8, 15, 30, 50]));
			matchPatternLevels[MatchPatterns.FIVE_OR_MORE_IN_A_ROW] = new MatchPatternLevel(MatchPatterns.FIVE_OR_MORE_IN_A_ROW, Vector.<int>([0, 0, 2, 5, 10, 18, 30]));
		}
	}
}