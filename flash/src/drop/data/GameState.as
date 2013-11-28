package drop.data
{
	public class GameState
	{
		public var credits : int;
		public var pendingCredits : int;
		public var inputs : Vector.<Input>;

		public var shouldStartSwap : Boolean;
		public var swapInProgress : Boolean;
		public var isTryingSwap : Boolean;
		public var isSwappingBack : Boolean;

		public var atLeastOneMatch : Boolean;

		public function GameState()
		{
			inputs = new Vector.<Input>();
		}
	}
}