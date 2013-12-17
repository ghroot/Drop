package drop.component
{
	import ash.tools.ComponentPool;

	import drop.data.*;
	import drop.util.EndlessValueSequence;

	import flash.utils.Dictionary;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	public class GameStateComponent
	{
		public var creditsUpdated : ISignal;
		public var pendingCreditsUpdated : ISignal;
		public var percentileUpdated : ISignal;

		public var inputs : Vector.<Input>;

		public var uniqueId : uint;

		public var credits : int;
		public var pendingCredits : int;
		public var pendingCreditsRecord : int;

		public var percentile : Number;
		public var isPercentileEnabled : Boolean;

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
			percentileUpdated = new Signal();
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

			uniqueId = 0;

			credits = 0;
			pendingCredits = 0;

			percentile = -1;
			isPercentileEnabled = false;

			shouldStartSwap = false;
			swapInProgress = false;
			isTryingSwap = false;
			isSwappingBack = false;

			matchInfos = new Vector.<MatchInfo>();
			matchInfoToHighlight = null;
			totalNumberOfMatchesDuringCascading = 0;
			totalNumberOfLineBlastsDuringCascading = 0;

			matchPatternLevels = new Dictionary();
			matchPatternLevels[MatchPatterns.THREE_IN_A_ROW] = new MatchPatternLevel(MatchPatterns.THREE_IN_A_ROW,
				new EndlessValueSequence(6,
					function(previousValue : int, currentValue : int) : int
					{
						return currentValue + (currentValue - previousValue) + 2;
					}),
				new EndlessValueSequence(3,
					function(previousValue : int, currentValue : int) : int
					{
						return currentValue + 1;
					}));
			matchPatternLevels[MatchPatterns.FOUR_IN_A_ROW] = new MatchPatternLevel(MatchPatterns.FOUR_IN_A_ROW,
				new EndlessValueSequence(3,
					function(previousValue : int, currentValue : int) : int
					{
						return currentValue + (currentValue - previousValue) + 1;
					}),
				new EndlessValueSequence(4,
					function(previousValue : int, currentValue : int) : int
					{
						return currentValue + 3;
					}));
			matchPatternLevels[MatchPatterns.T_OR_L] = new MatchPatternLevel(MatchPatterns.T_OR_L,
				new EndlessValueSequence(3,
					function(previousValue : int, currentValue : int) : int
					{
						return currentValue + (currentValue - previousValue) + 1;
					}),
				new EndlessValueSequence(4,
					function(previousValue : int, currentValue : int) : int
					{
						return currentValue + 3;
					}));
			matchPatternLevels[MatchPatterns.FIVE_OR_MORE_IN_A_ROW] = new MatchPatternLevel(MatchPatterns.FIVE_OR_MORE_IN_A_ROW,
				new EndlessValueSequence(2,
					function(previousValue : int, currentValue : int) : int
					{
						if (currentValue % 3 == 0)
						{
							return currentValue + (currentValue - previousValue) + 1;
						}
						else
						{
							return currentValue + (currentValue - previousValue);
						}
					}),
				new EndlessValueSequence(5,
					function(previousValue : int, currentValue : int) : int
					{
						return currentValue + 5;
					}));

//			for (var i : int = 0; i < 30; i++)
//			{
//				var s : String = "[" + i + "] ";
//				for each (var pattern : int in [MatchPatterns.THREE_IN_A_ROW, MatchPatterns.FOUR_IN_A_ROW, MatchPatterns.T_OR_L, MatchPatterns.FIVE_OR_MORE_IN_A_ROW])
//				{
//					s += toFixedLength("" + matchPatternLevels[pattern].requiredPoints.getValue(i), 6) + toFixedLength("(" + matchPatternLevels[pattern].creditYields.getValue(i) + ")", 6);
//				}
//				trace(s);
//			}

			isSelecting = false;
		}

//		private function toFixedLength(string : String, length : int) : String
//		{
//			while (string.length < length)
//			{
//				string += " ";
//			}
//			return string;
//		}

		public function withUniqueId(value : uint) : GameStateComponent
		{
			uniqueId = value;
			return this;
		}

		public function withCredits(value : int) : GameStateComponent
		{
			credits = value;
			return this;
		}

		public function withPendingCreditsRecord(value : int) : GameStateComponent
		{
			pendingCreditsRecord = value;
			return this;
		}

		public function withMatchPatternPoints(value : Object) : GameStateComponent
		{
			for (var pattern : * in value)
			{
				matchPatternLevels[pattern].points = value[pattern];
			}
			return this;
		}
	}
}