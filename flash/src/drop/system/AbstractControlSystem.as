package drop.system
{
	import ash.core.*;

	import drop.component.GameStateComponent;
	import drop.data.Input;
	import drop.node.GameNode;

	public class AbstractControlSystem extends System
	{
		private var inputTypes : Vector.<int>;

		private var gameNode : GameNode;

		public function AbstractControlSystem(inputTypes : Vector.<int>)
		{
			this.inputTypes = inputTypes;
		}

		override public function addToEngine(engine : Engine) : void
		{
			gameNode = engine.getNodeList(GameNode).head;
		}

		override public function update(time : Number) : void
		{
			var handledInputs : Vector.<Input> = null;
			for each (var input : Input in gameNode.gameStateComponent.inputs)
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
					gameNode.gameStateComponent.inputs.splice(gameNode.gameStateComponent.inputs.indexOf(input), 1);
				}
			}
		}

		protected function handleInput(input : Input) : void
		{
		}
	}
}