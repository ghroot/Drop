package drop.system
{
	import ash.core.Engine;
	import ash.core.System;

	import drop.node.GameNode;

	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.text.TextField;

	public class HudDisplaySystem extends System
	{
		private var creditsTextField : TextField;
		private var pendingCreditsTextField : TextField;
		private var pendingCreditsRecordSprite : Sprite;

		private var gameNode : GameNode;

		public function HudDisplaySystem(creditsTextField : TextField, pendingCreditsTextField : TextField, pendingCreditsRecordSprite : Sprite)
		{
			this.creditsTextField = creditsTextField;
			this.pendingCreditsTextField = pendingCreditsTextField;
			this.pendingCreditsRecordSprite = pendingCreditsRecordSprite;

			pendingCreditsTextField.visible = false;
			pendingCreditsRecordSprite.visible = false;
		}

		override public function addToEngine(engine : Engine) : void
		{
			gameNode = engine.getNodeList(GameNode).head;

			gameNode.gameStateComponent.creditsUpdated.add(onCreditsUpdated);
			gameNode.gameStateComponent.pendingCreditsUpdated.add(onPendingCreditsUpdated);

			creditsTextField.text = gameNode.gameStateComponent.credits.toString();
			pendingCreditsTextField.text = gameNode.gameStateComponent.pendingCredits.toString();
		}

		override public function removeFromEngine(engine : Engine) : void
		{
			gameNode.gameStateComponent.creditsUpdated.remove(onCreditsUpdated);
			gameNode.gameStateComponent.pendingCreditsUpdated.remove(onPendingCreditsUpdated);
		}

		private function onCreditsUpdated() : void
		{
			var proxy : Object = { "credits": parseInt(creditsTextField.text) };
			var tween : Tween = new Tween(proxy, 0.2);
			tween.animate("credits", gameNode.gameStateComponent.credits);
			tween.onUpdate = function() : void
			{
				creditsTextField.text = int(proxy.credits).toString();
			};
			Starling.juggler.add(tween);
		}

		private function onPendingCreditsUpdated() : void
		{
			if (gameNode.gameStateComponent.pendingCredits == 0)
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

				pendingCreditsRecordSprite.visible = false;
			}
			else
			{
				pendingCreditsTextField.visible = true;

				var proxy : Object = { "pendingCredits": parseInt(pendingCreditsTextField.text) };
				tween = new Tween(proxy, 0.2);
				tween.animate("pendingCredits", gameNode.gameStateComponent.pendingCredits);
				tween.onUpdate = function() : void
				{
					pendingCreditsTextField.text = "+" + int(proxy.pendingCredits) + " ";
				};
				Starling.juggler.add(tween);

				pendingCreditsRecordSprite.visible = gameNode.gameStateComponent.pendingCredits >= gameNode.gameStateComponent.pendingCreditsRecord;
			}
		}
	}
}
