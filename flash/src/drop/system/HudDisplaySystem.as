package drop.system
{
	import ash.core.Engine;
	import ash.core.System;

	import drop.node.GameNode;
	import drop.scene.SceneContainer;

	import starling.animation.Tween;
	import starling.core.Starling;

	public class HudDisplaySystem extends System
	{
		private var sceneContainer : SceneContainer;

		private var gameNode : GameNode;

		public function HudDisplaySystem(sceneContainer : SceneContainer)
		{
			this.sceneContainer = sceneContainer;

			sceneContainer.pendingCreditsTextField.visible = false;
			sceneContainer.pendingCreditsRecordSprite.visible = false;
		}

		override public function addToEngine(engine : Engine) : void
		{
			gameNode = engine.getNodeList(GameNode).head;

			gameNode.gameStateComponent.creditsUpdated.add(onCreditsUpdated);
			gameNode.gameStateComponent.pendingCreditsUpdated.add(onPendingCreditsUpdated);
			gameNode.gameStateComponent.percentileUpdated.add(onPercentileUpdated);

			sceneContainer.creditsTextField.text = gameNode.gameStateComponent.credits.toString();
			sceneContainer.pendingCreditsTextField.text = gameNode.gameStateComponent.pendingCredits.toString();
		}

		override public function removeFromEngine(engine : Engine) : void
		{
			gameNode.gameStateComponent.creditsUpdated.remove(onCreditsUpdated);
			gameNode.gameStateComponent.pendingCreditsUpdated.remove(onPendingCreditsUpdated);
			gameNode.gameStateComponent.percentileUpdated.remove(onPercentileUpdated);
		}

		private function onCreditsUpdated() : void
		{
			var proxy : Object = { "credits": parseInt(sceneContainer.creditsTextField.text) };
			var tween : Tween = new Tween(proxy, 0.2);
			tween.animate("credits", gameNode.gameStateComponent.credits);
			tween.onUpdate = function() : void
			{
				sceneContainer.creditsTextField.text = int(proxy.credits).toString();
			};
			Starling.juggler.add(tween);
		}

		private function onPendingCreditsUpdated() : void
		{
			if (gameNode.gameStateComponent.pendingCredits == 0)
			{
				const originalY : Number = sceneContainer.pendingCreditsTextField.y;
				var tween : Tween = new Tween(sceneContainer.pendingCreditsTextField, 0.3);
				tween.animate("y", originalY - 10);
				tween.animate("alpha", 0);
				tween.onComplete = function() : void
				{
					sceneContainer.pendingCreditsTextField.text = "0";
					sceneContainer.pendingCreditsTextField.y = originalY;
					sceneContainer.pendingCreditsTextField.alpha = 1;
					sceneContainer.pendingCreditsTextField.visible = false;
				};
				Starling.juggler.add(tween);

				sceneContainer.pendingCreditsRecordSprite.visible = false;
			}
			else
			{
				sceneContainer.pendingCreditsTextField.visible = true;

				var proxy : Object = { "pendingCredits": parseInt(sceneContainer.pendingCreditsTextField.text) };
				tween = new Tween(proxy, 0.2);
				tween.animate("pendingCredits", gameNode.gameStateComponent.pendingCredits);
				tween.onUpdate = function() : void
				{
					sceneContainer.pendingCreditsTextField.text = "+" + int(proxy.pendingCredits) + " ";
				};
				Starling.juggler.add(tween);

				sceneContainer.pendingCreditsRecordSprite.visible = gameNode.gameStateComponent.pendingCredits >= gameNode.gameStateComponent.pendingCreditsRecord;
			}
		}

		private function onPercentileUpdated() : void
		{
			updatePercentileImagePositions();
		}

		private function updatePercentileImagePositions() : void
		{
			if (!sceneContainer.percentileImagesContainer.visible)
			{
				sceneContainer.percentileImagesContainer.visible = true;
				sceneContainer.percentileImagesContainer.alpha = 0;
				var tween : Tween = new Tween(sceneContainer.percentileImagesContainer, 1);
				tween.animate("alpha", 1);
				Starling.juggler.add(tween);
			}

			var index : int = Math.min((1 - gameNode.gameStateComponent.percentile) * sceneContainer.percentileImages.length, sceneContainer.percentileImages.length - 1);
			for (var i : int = 0; i < sceneContainer.percentileImages.length; i++)
			{
				tween = new Tween(sceneContainer.percentileImages[i], 0.5);
				if (i == index)
				{
					tween.animate("y", -8);
				}
				else
				{
					tween.animate("y", 0);
				}
				Starling.juggler.add(tween);
			}
		}
	}
}
