package drop.board
{
	import ash.core.Engine;
	import ash.fsm.EngineState;
	import ash.fsm.EngineStateMachine;
	import ash.integration.starling.StarlingFixedTickProvider;
	import ash.tick.ITickProvider;

	import drop.data.GameState;
	import drop.system.AddPendingCreditsSystem;
	import drop.system.BoundsSystem;
	import drop.system.CascadingStateEndingSystem;
	import drop.system.CountdownSystem;
	import drop.system.DisplaySystem;
	import drop.system.FlySystem;
	import drop.system.HudDisplaySystem;
	import drop.system.LineBlastDetonationSystem;
	import drop.system.MatchingStateEndingSystem;
	import drop.system.MatchingSystem;
	import drop.system.MoveSystem;
	import drop.system.ScriptSystem;
	import drop.system.SelectControlSystem;
	import drop.system.SelectingStateEndingSystem;
	import drop.system.SpawnerSystem;
	import drop.system.SwapSystem;
	import drop.system.SwappingStateEndingSystem;
	import drop.system.SystemPriorities;
	import drop.system.TouchInputSystem;
	import drop.system.TurnEndStateEndingSystem;

	import flash.geom.Point;

	import starling.core.Starling;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.text.BitmapFont;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.utils.HAlign;
	import starling.utils.VAlign;

	public class Board extends Sprite
	{
		[Embed(source="../../../res/font.png")]
		public const FontBitmap : Class;

		[Embed(source="../../../res/font.fnt", mimeType="application/octet-stream")]
		public const FontXml : Class;

		[Embed(source="../../../res/fontSmall.png")]
		public const FontSmallBitmap : Class;

		[Embed(source="../../../res/fontSmall.fnt", mimeType="application/octet-stream")]
		public const FontSmallXml : Class;

		[Embed(source="../../../res/font-hd.png")]
		public const FontHdBitmap : Class;

		[Embed(source="../../../res/font-hd.fnt", mimeType="application/octet-stream")]
		public const FontHdXml : Class;

		[Embed(source="../../../res/fontSmall-hd.png")]
		public const FontSmallHdBitmap : Class;

		[Embed(source="../../../res/fontSmall-hd.fnt", mimeType="application/octet-stream")]
		public const FontSmallHdXml : Class;

		public function Board()
		{
		}

		public function start(scaleFactor : Number) : void
		{
			if (scaleFactor == 1)
			{
				TextField.registerBitmapFont(new BitmapFont(Texture.fromBitmap(new FontBitmap()), XML(new FontXml())), "Quicksand");
				TextField.registerBitmapFont(new BitmapFont(Texture.fromBitmap(new FontSmallBitmap()), XML(new FontSmallXml())), "QuicksandSmall");
			}
			else
			{
				TextField.registerBitmapFont(new BitmapFont(Texture.fromBitmap(new FontHdBitmap()), XML(new FontHdXml())), "Quicksand");
				TextField.registerBitmapFont(new BitmapFont(Texture.fromBitmap(new FontSmallHdBitmap()), XML(new FontSmallHdXml())), "QuicksandSmall");
			}

			var boardSize : Point = new Point(7, 7);
			var modelTileSize : int = 44;
			var viewTileSize : int = modelTileSize * scaleFactor;

			var touchQuad : Quad = new Quad(boardSize.x * viewTileSize, boardSize.y * viewTileSize, 0xffffff);
			touchQuad.x = touchQuad.y = (stage.stageWidth - boardSize.x * viewTileSize) / 2;
			addChild(touchQuad);

			var boardContainer : Sprite = new Sprite();
			boardContainer.x = boardContainer.y = (stage.stageWidth - boardSize.x * viewTileSize) / 2;
			boardContainer.touchable = false;
			addChild(boardContainer);

			var textField : TextField = new TextField(stage.stageWidth, stage.stageHeight - boardSize.y * viewTileSize, "0", "Quicksand", 60 * scaleFactor);
			textField.hAlign = HAlign.CENTER;
			textField.vAlign = VAlign.CENTER;
			textField.y = boardSize.y * viewTileSize;
			addChild(textField);

			var statusTextField : TextField = new TextField(stage.stageWidth, 30 * scaleFactor, "", "QuicksandSmall", 20 * scaleFactor);
			statusTextField.hAlign = HAlign.CENTER;
			statusTextField.vAlign = VAlign.TOP;
			statusTextField.y = textField.y + int(textField.height / 2) + 24 * scaleFactor;
			addChild(statusTextField);

			var gameState : GameState = new GameState();

			var engine : Engine = new Engine();

			var entityManager : EntityManager = new EntityManager(engine, boardSize, modelTileSize, viewTileSize, scaleFactor);

			var matcher : Matcher = new Matcher(boardSize, modelTileSize);

			for (var row : int = 0; row < boardSize.y; row++)
			{
				for (var column : int = 0; column < boardSize.x; column++)
				{
					var x : Number = column * modelTileSize;
					var y : Number = row * modelTileSize;
					if (row == 0)
					{
						engine.addEntity(entityManager.createSpawner(x, y));
					}
					if ((row == 2 || row == 5) &&
							(column == 1 || column == 5))
					{
						engine.addEntity(entityManager.createBlocker(x, y));
					}
					else
					{
						engine.addEntity(entityManager.createTile(x, y));
					}
				}
			}

			var stateMachine : EngineStateMachine = new EngineStateMachine(engine);

			var selectingState : EngineState = stateMachine.createState("selecting");
			selectingState.addInstance(new TouchInputSystem(touchQuad, scaleFactor, gameState)).withPriority(SystemPriorities.INPUT);
			selectingState.addInstance(new SelectControlSystem(gameState, modelTileSize)).withPriority(SystemPriorities.CONTROL);
			selectingState.addInstance(new SelectingStateEndingSystem(stateMachine, gameState)).withPriority(SystemPriorities.END);

			var swappingState : EngineState = stateMachine.createState("swapping");
			swappingState.addInstance(new SwapSystem(gameState)).withPriority(SystemPriorities.LOGIC);
			swappingState.addInstance(new SwappingStateEndingSystem(stateMachine, gameState)).withPriority(SystemPriorities.END);

			var matchingState : EngineState = stateMachine.createState("matching");
			matchingState.addInstance(new MatchingSystem(matcher, gameState)).withPriority(SystemPriorities.LOGIC);
			matchingState.addInstance(new MatchingStateEndingSystem(stateMachine, gameState)).withPriority(SystemPriorities.END);

			var cascadingState : EngineState = stateMachine.createState("cascading");
			cascadingState.addInstance(new LineBlastDetonationSystem(entityManager, boardSize, modelTileSize, gameState)).withPriority(SystemPriorities.LOGIC);
			cascadingState.addInstance(new SpawnerSystem(modelTileSize, entityManager)).withPriority(SystemPriorities.LOGIC);
			cascadingState.addInstance(new MoveSystem(boardSize, modelTileSize)).withPriority(SystemPriorities.LOGIC);
			cascadingState.addInstance(new CascadingStateEndingSystem(stateMachine)).withPriority(SystemPriorities.END);

			var turnEndState : EngineState = stateMachine.createState("turnEnd");
			turnEndState.addInstance(new AddPendingCreditsSystem(gameState)).withPriority(SystemPriorities.LOGIC);
			turnEndState.addInstance(new TurnEndStateEndingSystem(stateMachine)).withPriority(SystemPriorities.END);

			engine.addSystem(new FlySystem(), SystemPriorities.LOGIC);
			engine.addSystem(new BoundsSystem(entityManager), SystemPriorities.LOGIC);
			engine.addSystem(new CountdownSystem(entityManager), SystemPriorities.LOGIC);
			engine.addSystem(new ScriptSystem(), SystemPriorities.LOGIC);
			engine.addSystem(new HudDisplaySystem(textField, statusTextField, gameState), SystemPriorities.DISPLAY);
			engine.addSystem(new DisplaySystem(boardContainer, scaleFactor, viewTileSize), SystemPriorities.DISPLAY);

			stateMachine.changeState("selecting");

			var tickProvider : ITickProvider = new StarlingFixedTickProvider(Starling.juggler, 0.017);
			tickProvider.add(engine.update);
			tickProvider.start();
		}
	}
}
