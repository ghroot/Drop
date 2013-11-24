package drop.system
{
	import ash.core.*;

	import drop.data.GameState;
	import drop.data.Input;

	public class AbstractControlSystem extends System
	{
		protected var gameState : GameState;
		private var inputTypes : Vector.<int>;

		public function AbstractControlSystem(gameState : GameState, inputTypes : Vector.<int>)
		{
			this.gameState = gameState;
			this.inputTypes = inputTypes;
		}

		override public function update(time : Number) : void
		{
			var handledInputs : Vector.<Input> = null;
			for each (var input : Input in gameState.inputs)
			{
				if (inputTypes.indexOf(input.type) >= 0)
				{
					if (handledInputs == null)
					{
						handledInputs = new Vector.<Input>();
					}
					handledInputs[handledInputs.length] = input;
					handleInput(input);
				}
			}
			if (handledInputs != null)
			{
				for each (input in handledInputs)
				{
					gameState.inputs.splice(gameState.inputs.indexOf(input), 1);
				}
			}
		}

		protected function handleInput(input : Input) : void
		{
		}
	}
}