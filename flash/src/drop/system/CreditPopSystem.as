package drop.system
{
	import ash.core.System;

	import drop.data.GameState;

	import drop.data.MatchInfo;
	import drop.util.DisplayUtils;

	import starling.animation.Transitions;

	import starling.animation.Tween;
	import starling.core.Starling;

	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.utils.Color;
	import starling.utils.HAlign;
	import starling.utils.VAlign;

	public class CreditPopSystem extends System
	{
		private var overlayContainer : Sprite;
		private var gameState : GameState;
		private var scaleFactor : Number;
		private var viewTileSize : int;

		public function CreditPopSystem(overlayContainer : Sprite, gameState : GameState, scaleFactor : Number, viewTileSize : int)
		{
			this.overlayContainer = overlayContainer;
			this.gameState = gameState;
			this.scaleFactor = scaleFactor;
			this.viewTileSize = viewTileSize;
		}

		override public function update(time : Number) : void
		{
			for each (var matchInfo : MatchInfo in gameState.matchInfos)
			{
				var creditPopSprite : Sprite = new Sprite();
				creditPopSprite.x = matchInfo.positionX + viewTileSize / 2;
				creditPopSprite.y = matchInfo.positionY + viewTileSize / 2;

				var shadowTextField : TextField = new TextField(200, 30, matchInfo.numberOfCredits.toString(), "QuicksandSmall", 20 * scaleFactor, Color.BLACK);
				shadowTextField.x = 1;
				shadowTextField.y = 1;
				shadowTextField.hAlign = HAlign.CENTER;
				shadowTextField.vAlign = VAlign.CENTER;
				DisplayUtils.centerPivot(shadowTextField);
				creditPopSprite.addChild(shadowTextField);

				var textField : TextField = new TextField(200, 30, matchInfo.numberOfCredits.toString(), "QuicksandSmall", 20 * scaleFactor, Color.WHITE);
				textField.hAlign = HAlign.CENTER;
				textField.vAlign = VAlign.CENTER;
				DisplayUtils.centerPivot(textField);
				creditPopSprite.addChild(textField);

				overlayContainer.addChild(creditPopSprite);

				var tween : Tween = new Tween(creditPopSprite, 1, Transitions.EASE_OUT);
				tween.animate("y", creditPopSprite.y - 10 * scaleFactor);
				tween.onCompleteArgs = [creditPopSprite];
				tween.onComplete = function(creditPopSprite : Sprite) : void
				{
					overlayContainer.removeChild(creditPopSprite);
				};
				Starling.juggler.add(tween);
			}
		}
	}
}
