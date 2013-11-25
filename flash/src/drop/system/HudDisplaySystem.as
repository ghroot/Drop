package drop.system
{
	import ash.core.System;

	import drop.data.GameState;

	import starling.animation.Tween;

	import starling.text.TextField;

	public class HudDisplaySystem extends System
	{
		private var gameState : GameState;
		private var textField : TextField;

		private var currentCredits : int;
		private var tween : Tween;

		public function HudDisplaySystem(textField : TextField, gameState : GameState)
		{
			this.textField = textField;
			this.gameState = gameState;

			currentCredits = -1;
		}

		override public function update(time : Number) : void
		{
			if (currentCredits != gameState.credits)
			{
				var proxy : Object = { "credits": currentCredits };
				tween = new Tween(proxy, 0.2);
				tween.animate("credits", gameState.credits);
				tween.onUpdate = function() : void
				{
					textField.text = int(proxy.credits).toString();
				};

				currentCredits = gameState.credits;
			}

			if (tween != null)
			{
				tween.advanceTime(time);
				if (tween.isComplete)
				{
					tween = null;
				}
			}
		}
	}
}
