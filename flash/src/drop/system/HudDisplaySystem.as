package drop.system
{
	import ash.core.System;

	import drop.data.GameState;

	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.text.TextField;

	public class HudDisplaySystem extends System
	{
		private var gameState : GameState;
		private var creditsTextField : TextField;
		private var pendingCreditsTextField : TextField;

		public function HudDisplaySystem(creditsTextField : TextField, pendingCreditsTextField : TextField, gameState : GameState)
		{
			this.creditsTextField = creditsTextField;
			this.pendingCreditsTextField = pendingCreditsTextField;
			this.gameState = gameState;

			pendingCreditsTextField.visible = false;

			gameState.creditsUpdated.add(onCreditsUpdated);
			gameState.pendingCreditsUpdated.add(onPendingCreditsUpdated);
		}

		private function onCreditsUpdated(credits : int) : void
		{
			var proxy : Object = { "credits": parseInt(creditsTextField.text) };
			var tween : Tween = new Tween(proxy, 0.2);
			tween.animate("credits", gameState.credits);
			tween.onUpdate = function() : void
			{
				creditsTextField.text = int(proxy.credits).toString();
			};
			Starling.juggler.add(tween);
		}

		private function onPendingCreditsUpdated(pendingCredits : int) : void
		{
			if (pendingCredits == 0)
			{
				const originalY : Number = pendingCreditsTextField.y;
				var tween : Tween = new Tween(pendingCreditsTextField, 0.3);
				tween.animate("y", originalY - 10);
				tween.animate("alpha", 0);
				tween.onComplete = function() : void
				{
					pendingCreditsTextField.text = "0";
					pendingCreditsTextField.y = originalY;
					pendingCreditsTextField.alpha = 1;
					pendingCreditsTextField.visible = false;
				};
				Starling.juggler.add(tween);
			}
			else
			{
				pendingCreditsTextField.visible = true;

				var proxy : Object = { "pendingCredits": parseInt(pendingCreditsTextField.text) };
				tween = new Tween(proxy, 0.2);
				tween.animate("pendingCredits", gameState.pendingCredits);
				tween.onUpdate = function() : void
				{
					pendingCreditsTextField.text = "+" + int(proxy.pendingCredits) + " ";
				};
				Starling.juggler.add(tween);
			}
		}
	}
}
