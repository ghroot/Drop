package drop.board
{
	import ash.core.Engine;
	import ash.fsm.EngineState;
	import ash.fsm.EngineStateMachine;
	import ash.integration.starling.StarlingFixedTickProvider;
	import ash.tick.ITickProvider;

	import drop.data.GameState;
	import drop.system.BoundsSystem;
	import drop.system.CascadingStateEndingSystem;
	import drop.system.CountdownSystem;
	import drop.system.DeselectSystem;
	import drop.system.DisplaySystem;
	import drop.system.FlySystem;
	import drop.system.HudDisplaySystem;
	import drop.system.LineBlastDetonationSystem;
	import drop.system.LineBlastPulseSystem;
	import drop.system.MatchingStateEndingSystem;
	import drop.system.MatchingSystem;
	import drop.system.MoveSystem;
	import drop.system.SelectControlSystem;
	import drop.system.SelectingStateEndingSystem;
	import drop.system.SpawnerSystem;
	import drop.system.SubmittingStateEndingSystem;
	import drop.system.SwapSystem;
	import drop.system.SystemPriorities;
	import drop.system.TouchInputSystem;

	import flash.geom.Point;

	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.text.BitmapFont;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.textures.Texture;
	import starling.utils.AssetManager;
	import starling.utils.HAlign;
	import starling.utils.VAlign;

	public class Board extends Sprite
	{
		[Embed(source="../../../res/font.png")]
		public const FontBitmap : Class;

		[Embed(source="../../../res/font.fnt", mimeType="application/octet-stream")]
		public const FontXml : Class;

		public function Board()
		{
		}

		public function start(startupTexture : Texture, assets : AssetManager) : void
		{
//			addChild(new Image(startupTexture));

			TextField.registerBitmapFont(new BitmapFont(Texture.fromBitmap(new FontBitmap()), XML(new FontXml())), "Quicksand");

			var boardSize : Point = new Point(7, 7);
			var tileSize : int = int((320 - 10) / boardSize.x);

			var touchQuad : Quad = new Quad(boardSize.x * tileSize, boardSize.y * tileSize, 0xffffff);
			touchQuad.x = touchQuad.y = (stage.stageWidth - boardSize.x * tileSize) / 2;
			addChild(touchQuad);

			var boardContainer : Sprite = new Sprite();
			boardContainer.x = boardContainer.y = (stage.stageWidth - boardSize.x * tileSize) / 2;
			boardContainer.touchable = false;
			addChild(boardContainer);

			var textField : TextField = new TextField(stage.stageWidth, stage.stageHeight - boardSize.y * tileSize, "0", "Quicksand", 60);
			textField.name = "textField";
			textField.hAlign = HAlign.CENTER;
			textField.vAlign = VAlign.CENTER;
			textField.y = boardSize.y * tileSize;
			addChild(textField);

			var gameState : GameState = new GameState();

			var engine : Engine = new Engine();

			var entityManager : EntityManager = new EntityManager(engine, boardSize, tileSize);

			var matcher : Matcher = new Matcher(boardSize, tileSize);

			for (var row : int = 0; row < boardSize.y; row++)
			{
				for (var column : int = 0; column < boardSize.x; column++)
				{
					var x : Number = column * tileSize;
					var y : Number = row * tileSize;
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
			selectingState.addInstance(new TouchInputSystem(touchQuad, gameState)).withPriority(SystemPriorities.INPUT);
			selectingState.addInstance(new SelectControlSystem(gameState, tileSize)).withPriority(SystemPriorities.CONTROL);
			selectingState.addInstance(new SelectingStateEndingSystem(stateMachine, gameState)).withPriority(SystemPriorities.END);

			var submittingState : EngineState = stateMachine.createState("submitting");
			submittingState.addInstance(new SwapSystem(matcher)).withPriority(SystemPriorities.LOGIC);
			submittingState.addInstance(new DeselectSystem()).withPriority(SystemPriorities.POST_LOGIC);
			submittingState.addInstance(new SubmittingStateEndingSystem(stateMachine)).withPriority(SystemPriorities.END);

			var matchingState : EngineState = stateMachine.createState("matching");
			matchingState.addInstance(new MatchingSystem(matcher, gameState)).withPriority(SystemPriorities.LOGIC);
			matchingState.addInstance(new MatchingStateEndingSystem(stateMachine, gameState)).withPriority(SystemPriorities.END);

			var cascadingState : EngineState = stateMachine.createState("cascading");
			cascadingState.addInstance(new LineBlastDetonationSystem(entityManager)).withPriority(SystemPriorities.LOGIC);
			cascadingState.addInstance(new LineBlastPulseSystem(tileSize)).withPriority(SystemPriorities.LOGIC);
			cascadingState.addInstance(new SpawnerSystem(tileSize, entityManager)).withPriority(SystemPriorities.LOGIC);
			cascadingState.addInstance(new MoveSystem(boardSize, tileSize)).withPriority(SystemPriorities.LOGIC);
			cascadingState.addInstance(new CascadingStateEndingSystem(stateMachine)).withPriority(SystemPriorities.END);

			engine.addSystem(new FlySystem(), SystemPriorities.LOGIC);
			engine.addSystem(new BoundsSystem(entityManager), SystemPriorities.LOGIC);
			engine.addSystem(new CountdownSystem(entityManager), SystemPriorities.LOGIC);
			engine.addSystem(new HudDisplaySystem(textField, gameState), SystemPriorities.DISPLAY);
			engine.addSystem(new DisplaySystem(boardContainer), SystemPriorities.DISPLAY);

			stateMachine.changeState("selecting");

			var tickProvider : ITickProvider = new StarlingFixedTickProvider(Starling.juggler, 0.017);
			tickProvider.add(engine.update);
			tickProvider.start();
		}
	}
}
