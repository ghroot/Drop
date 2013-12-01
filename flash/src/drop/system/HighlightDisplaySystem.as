package drop.system
{
	import ash.core.Engine;
	import ash.core.System;

	import drop.data.GameState;
	import drop.data.MatchInfo;
	import drop.data.MatchPatternLevel;
	import drop.util.MathUtils;

	import flash.geom.Point;
	import flash.geom.Rectangle;

	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.utils.Color;
	import starling.utils.HAlign;
	import starling.utils.VAlign;

	public class HighlightDisplaySystem extends System
	{
		private var container : Sprite;
		private var scaleFactor : Number;
		private var boardSize : Point;
		private var viewTileSize : int;
		private var gameState : GameState;

		private var textField : TextField;

		public function HighlightDisplaySystem(container : Sprite, scaleFactor : Number, boardSize : Point, viewTileSize : int, gameState : GameState)
		{
			this.container = container;
			this.scaleFactor = scaleFactor;
			this.boardSize = boardSize;
			this.viewTileSize = viewTileSize;
			this.gameState = gameState;

			textField = new TextField(150 * scaleFactor, 100 * scaleFactor, "", "QuicksandSmall", 20 * scaleFactor, Color.BLACK);
			textField.hAlign = HAlign.CENTER;
			textField.vAlign = VAlign.CENTER;
		}

		override public function addToEngine(engine : Engine) : void
		{
			var matchPatternLevel : MatchPatternLevel = gameState.matchPatternLevels[gameState.matchInfoToHighlight.pattern];
			textField.text = "This pattern now gives " + (gameState.matchInfoToHighlight.positions.length + matchPatternLevel.getNumberOfBonusCredits()) + " points.";

			var bounds : Rectangle = getMatchBounds(gameState.matchInfoToHighlight);
			var spaceUp : Number = bounds.y;
			var spaceDown : Number = boardSize.y * viewTileSize - (bounds.y + bounds.height);
			var spaceLeft : Number = bounds.x;
			var spaceRight : Number = boardSize.x * viewTileSize - (bounds.x + bounds.width);
			var max : Number = maxOfFour(spaceUp, spaceDown, spaceLeft, spaceRight);
			if (max == spaceUp)
			{
				textField.pivotX = textField.width / 2;
				textField.pivotY = textField.height;
				textField.x = bounds.x + bounds.width / 2;
				textField.y = bounds.y - 10 * scaleFactor;
			}
			else if (max == spaceDown)
			{
				textField.pivotX = textField.width / 2;
				textField.pivotY = 0;
				textField.x = bounds.x + bounds.width / 2;
				textField.y = bounds.y + + bounds.height + 10 * scaleFactor;
			}
			else if (max == spaceLeft)
			{
				textField.pivotX = textField.width;
				textField.pivotY = textField.height / 2;
				textField.x = bounds.x - 10 * scaleFactor;
				textField.y = bounds.y + bounds.height / 2;
			}
			else
			{
				textField.pivotX = 0;
				textField.pivotY = textField.height / 2;
				textField.x = bounds.x + bounds.width + 10 * scaleFactor;
				textField.y = bounds.y + bounds.height / 2;
			}

			textField.alpha = 0;
			var fadeInTween : Tween = new Tween(textField, 0.5);
			fadeInTween.delay = 1;
			fadeInTween.animate("alpha", 1);
			Starling.juggler.add(fadeInTween);
			var fadeOutTween : Tween = new Tween(textField, 0.5);
			fadeOutTween.delay = 3;
			fadeOutTween.animate("alpha", 0);
			Starling.juggler.add(fadeOutTween);

			container.addChild(textField);
		}

		override public function removeFromEngine(engine : Engine) : void
		{
			container.removeChild(textField);
		}

		private function getMatchBounds(matchInfo : MatchInfo) : Rectangle
		{
			var leftMostX : Number = Number.MAX_VALUE;
			var rightMostX : Number = Number.MIN_VALUE;
			var topMostY : Number = Number.MAX_VALUE;
			var bottomMostY : Number = Number.MIN_VALUE;
			for each (var position : Point in matchInfo.positions)
			{
				leftMostX = MathUtils.min(leftMostX, position.x * scaleFactor);
				rightMostX = MathUtils.max(rightMostX, position.x * scaleFactor);
				topMostY = MathUtils.min(topMostY, position.y * scaleFactor);
				bottomMostY = MathUtils.max(bottomMostY, position.y * scaleFactor);
			}
			return new Rectangle(leftMostX, topMostY, rightMostX - leftMostX + viewTileSize, bottomMostY - topMostY + viewTileSize);
		}

		private function maxOfFour(a : Number, b : Number, c : Number, d : Number) : Number
		{
			if (a >= b && a >= c && a >= d)
			{
				return a;
			}
			else if (b >= a && b >= c && b >= d)
			{
				return b;
			}
			else if (c >= a && c >= b && c >= d)
			{
				return c;
			}
			else
			{
				return d;
			}
		}
	}
}
