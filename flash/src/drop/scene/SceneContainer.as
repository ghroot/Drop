package drop.scene
{
	import drop.util.DisplayUtils;

	import flash.geom.Point;

	import starling.display.BlendMode;
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.utils.AssetManager;
	import starling.utils.Color;
	import starling.utils.HAlign;
	import starling.utils.VAlign;

	public class SceneContainer extends Sprite
	{
		private var assets : AssetManager;
		private var boardSize : Point;
		private var tileSize : int;

		public var boardPosition : Point;
		public var boardContainer : Sprite;
		public var touchQuad : Quad;
		public var spawnerButtonsContainer : Sprite;
		public var spawnerButtons : Vector.<Button>;
		public var overlayContainer : Sprite;
		public var creditsTextField : TextField;
		public var pendingCreditsTextField : TextField;
		public var pendingCreditsRecordSprite : Sprite;
		public var percentileImagesContainer : Sprite;
		public var percentileImages : Vector.<Image>;
		public var bottomTouchQuad : Quad;

		public function SceneContainer(assets : AssetManager, boardSize : Point, tileSize : int)
		{
			this.assets = assets;
			this.boardSize = boardSize;
			this.tileSize = tileSize;

			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}

		private function onAddedToStage(event : Event) : void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

			var padding : Number = (stage.stageWidth - boardSize.x * tileSize) / 2;
			boardPosition = new Point(padding, padding);

			var backgroundImage : Image = new Image(assets.getTexture("background"));
			backgroundImage.touchable = true;
			backgroundImage.blendMode = BlendMode.NONE;
			addChild(backgroundImage);

			touchQuad = new Quad(boardSize.x * tileSize, boardSize.y * tileSize);
			touchQuad.x = boardPosition.x;
			touchQuad.y = boardPosition.y;
			touchQuad.alpha = 0;
			touchQuad.blendMode = BlendMode.NONE;
			addChild(touchQuad);

			boardContainer = new Sprite();
			boardContainer.x = boardPosition.x;
			boardContainer.y = boardPosition.y;
			boardContainer.touchable = false;
			addChild(boardContainer);

			spawnerButtons = new Vector.<Button>();
			spawnerButtonsContainer = new Sprite();
			spawnerButtonsContainer.x = boardPosition.x;
			spawnerButtonsContainer.y = boardPosition.y - tileSize;
			for (var column : int = 0; column < boardSize.x; column++)
			{
				var spawnerButton : Button = new Button(assets.getTexture("spawner"), "");
				spawnerButton.fontName = "fontSmall";
				spawnerButton.fontSize = 20;
				spawnerButton.fontColor = Color.WHITE;
				spawnerButton.x = column * tileSize;
				spawnerButtonsContainer.addChild(spawnerButton);
				spawnerButtons[spawnerButtons.length] = spawnerButton;
			}
			spawnerButtonsContainer.alpha = 0;
			addChild(spawnerButtonsContainer);

			overlayContainer = new Sprite();
			overlayContainer.x = boardPosition.x;
			overlayContainer.y = boardPosition.y;
			overlayContainer.touchable = false;
			addChild(overlayContainer);

			creditsTextField = new TextField(stage.stageWidth, 70, "0", "font", 60)
			creditsTextField.hAlign = HAlign.CENTER;
			creditsTextField.vAlign = VAlign.CENTER;
			DisplayUtils.centerPivot(creditsTextField);
			creditsTextField.x = stage.stageWidth / 2;
			creditsTextField.y = boardPosition.y + boardSize.y * tileSize + (stage.stageHeight - boardSize.y * tileSize - boardPosition.y) / 2;
			creditsTextField.touchable = false;
			addChild(creditsTextField);

			pendingCreditsTextField = new TextField(stage.stageWidth, 30, "0", "fontSmall", 20);
			pendingCreditsTextField.hAlign = HAlign.CENTER;
			pendingCreditsTextField.vAlign = VAlign.TOP;
			pendingCreditsTextField.y = creditsTextField.y + 26;
			pendingCreditsTextField.touchable = false;
			addChild(pendingCreditsTextField);

			pendingCreditsRecordSprite = new Sprite();
			pendingCreditsRecordSprite.x = stage.stageWidth / 2;
			pendingCreditsRecordSprite.y = creditsTextField.y + 54;
			pendingCreditsRecordSprite.touchable = false;
			addChild(pendingCreditsRecordSprite);

			var pendingCreditsRecordBackground : Quad = new Quad(72, 18, Color.BLACK);
			DisplayUtils.centerPivotX(pendingCreditsRecordBackground);
			pendingCreditsRecordSprite.addChild(pendingCreditsRecordBackground);

			var pendingCreditsRecordTextField : TextField = new TextField(stage.stageWidth, 30, "RECORD", "fontSmall", 16, Color.WHITE);
			pendingCreditsRecordTextField.hAlign = HAlign.CENTER;
			pendingCreditsRecordTextField.vAlign = VAlign.TOP;
			DisplayUtils.centerPivotX(pendingCreditsRecordTextField);
			pendingCreditsRecordSprite.addChild(pendingCreditsRecordTextField);

			percentileImages = new Vector.<Image>();
			percentileImagesContainer = new Sprite();
			percentileImagesContainer.x = 10;
			percentileImagesContainer.y = stage.stageHeight + 40;
			var percentileTexture : Texture = assets.getTexture("percentile");
			for (var i : int = 0; i < 50; i++)
			{
				var percentileImage : Image = new Image(percentileTexture);
				percentileImage.x = i * (percentileTexture.width + 1);
				percentileImage.pivotY = percentileImage.height;
				percentileImagesContainer.addChild(percentileImage);
				percentileImages[percentileImages.length] = percentileImage;
			}
			percentileImagesContainer.visible = false;
			addChild(percentileImagesContainer);

			bottomTouchQuad = new Quad(stage.stageWidth, stage.stageHeight - boardSize.y * tileSize - boardPosition.y);
			bottomTouchQuad.y = boardPosition.y + boardSize.y * tileSize + boardPosition.y;
			bottomTouchQuad.alpha = 0;
			bottomTouchQuad.blendMode = BlendMode.NONE;
			addChild(bottomTouchQuad);
		}
	}
}
