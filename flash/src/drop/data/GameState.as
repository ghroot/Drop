package drop.data
{
	public class GameState
	{
		public var inputs : Vector.<Input>;
		public var shouldSubmitCurrentSelection : Boolean;

		public function GameState()
		{
			inputs = new Vector.<Input>();
		}
	}
}