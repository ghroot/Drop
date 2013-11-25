package drop.data
{
	public class GameState
	{
		public var credits : int;
		public var inputs : Vector.<Input>;
		public var shouldSubmit : Boolean;
		public var atLeastOneMatch : Boolean;

		public function GameState()
		{
			inputs = new Vector.<Input>();
		}
	}
}