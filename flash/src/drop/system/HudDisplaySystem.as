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
		private var statusTextField : TextField;

		private var currentCredits : int;
		private var currentPendingCredits : int;
		private var tween : Tween;
		private var statusTween : Tween;

		public function HudDisplaySystem(textField : TextField, statusTextField : TextField, gameState : GameState)
		{
			this.textField = textField;
			this.statusTextField = statusTextField;
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

			if (currentPendingCredits != gameState.pendingCredits)
			{
				if (gameState.pendingCredits == 0)
				{
					const originalY : Number = statusTextField.y;
					statusTween = new Tween(statusTextField, 0.3);
					statusTween.animate("y", originalY - 10);
					statusTween.animate("alpha", 0);
					statusTween.onComplete = function() : void
					{
						statusTextField.y = originalY;
						statusTextField.alpha = 1;
						statusTextField.text = "";
					}
				}
				else
				{
					proxy = { "pendingCredits": currentPendingCredits };
					tween = new Tween(proxy, 0.2);
					tween.animate("pendingCredits", gameState.pendingCredits);
					tween.onUpdate = function() : void
					{
						statusTextField.text = "+" + int(proxy.pendingCredits) + " ";
					};
				}

				currentPendingCredits = gameState.pendingCredits;
			}

			if (tween != null)
			{
				tween.advanceTime(time);
				if (tween.isComplete)
				{
					tween = null;
				}
			}
			if (statusTween != null)
			{
				statusTween.advanceTime(time);
				if (statusTween.isComplete)
				{
					statusTween = null;
				}
			}
		}
	}
}
