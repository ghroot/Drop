package drop.system
{
	import ash.core.Engine;
	import ash.core.System;

	import drop.data.MatchInfo;
	import drop.data.MatchPatternLevel;
	import drop.node.GameNode;
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
		private var boardSize : Point;
		private var tileSize : int;

		private var gameNode : GameNode;
		private var textField : TextField;

		public function HighlightDisplaySystem(container : Sprite, boardSize : Point, tileSize : int)
		{
			this.container = container;
			this.boardSize = boardSize;
			this.tileSize = tileSize;

			textField = new TextField(150, 100, "", "fontSmall", 20, Color.BLACK);
			textField.hAlign = HAlign.CENTER;
			textField.vAlign = VAlign.CENTER;
		}

		override public function addToEngine(engine : Engine) : void
		{
			gameNode = engine.getNodeList(GameNode).head;

			var matchPatternLevel : MatchPatternLevel = gameNode.gameStateComponent.matchPatternLevels[gameNode.gameStateComponent.matchInfosToHighlight[0].pattern];
			textField.text = "This shape now gives " + matchPatternLevel.getCreditYield() + " points.";

			var bounds : Rectangle = getMatchBounds(gameNode.gameStateComponent.matchInfosToHighlight[0]);
			var spaceUp : Number = bounds.y;
			var spaceDown : Number = boardSize.y * tileSize - (bounds.y + bounds.height);
			var spaceLeft : Number = bounds.x;
			var spaceRight : Number = boardSize.x * tileSize - (bounds.x + bounds.width);
			var max : Number = maxOfFour(spaceUp, spaceDown, spaceLeft, spaceRight);
			if (max == spaceUp)
			{
				textField.pivotX = textField.width / 2;
				textField.pivotY = textField.height;
				textField.x = bounds.x + bounds.width / 2;
				textField.y = bounds.y - 10;
			}
			else if (max == spaceDown)
			{
				textField.pivotX = textField.width / 2;
				textField.pivotY = 0;
				textField.x = bounds.x + bounds.width / 2;
				textField.y = bounds.y + + bounds.height + 10;
			}
			else if (max == spaceLeft)
			{
				textField.pivotX = textField.width;
				textField.pivotY = textField.height / 2;
				textField.x = bounds.x - 10;
				textField.y = bounds.y + bounds.height / 2;
			}
			else
			{
				textField.pivotX = 0;
				textField.pivotY = textField.height / 2;
				textField.x = bounds.x + bounds.width + 10;
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
				leftMostX = MathUtils.min(leftMostX, position.x);
				rightMostX = MathUtils.max(rightMostX, position.x);
				topMostY = MathUtils.min(topMostY, position.y);
				bottomMostY = MathUtils.max(bottomMostY, position.y);
			}
			return new Rectangle(leftMostX, topMostY, rightMostX - leftMostX + tileSize, bottomMostY - topMostY + tileSize);
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
