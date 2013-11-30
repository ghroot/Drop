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
	import drop.system.ComboSystem;
	import drop.system.CountdownSystem;
	import drop.system.DisplaySystem;
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
	import drop.util.DisplayUtils;

	import flash.geom.Point;

	import starling.core.Starling;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;

	public class Board extends Sprite
	{
		private var scaleFactor : Number;

		public function Board(scaleFactor : Number)
		{
			this.scaleFactor = scaleFactor;

			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}

		private function onAddedToStage(event : Event) : void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

			var boardSize : Point = new Point(7, 7);
			var modelTileSize : int = 44;
			var viewTileSize : int = modelTileSize * scaleFactor;

			var backgroundQuad : Quad = new Quad(stage.stageWidth, stage.stageHeight, 0xffffff);
			backgroundQuad.touchable = false;
			addChild(backgroundQuad);

			var touchQuad : Quad = new Quad(boardSize.x * viewTileSize, boardSize.y * viewTileSize, 0xffffff);
			touchQuad.x = touchQuad.y = (stage.stageWidth - boardSize.x * viewTileSize) / 2;
			addChild(touchQuad);

			var boardContainer : Sprite = new Sprite();
			boardContainer.x = boardContainer.y = (stage.stageWidth - boardSize.x * viewTileSize) / 2;
			boardContainer.touchable = false;
			addChild(boardContainer);

			var overlayContainer : Sprite = new Sprite();
			overlayContainer.x = boardContainer.x;
			overlayContainer.touchable = false;
			addChild(overlayContainer);

			var creditsTextField : TextField = new TextField(stage.stageWidth, 70 * scaleFactor, "0", "Quicksand", 60 * scaleFactor);
			creditsTextField.x = stage.stageWidth / 2;
			creditsTextField.hAlign = HAlign.CENTER;
			creditsTextField.vAlign = VAlign.CENTER;
			DisplayUtils.centerPivot(creditsTextField);
			creditsTextField.y = boardSize.y * viewTileSize + (stage.stageHeight - boardSize.y * viewTileSize) /2;
			addChild(creditsTextField);

			var pendingCreditsTextField : TextField = new TextField(stage.stageWidth, 30 * scaleFactor, "0", "QuicksandSmall", 20 * scaleFactor);
			pendingCreditsTextField.hAlign = HAlign.CENTER;
			pendingCreditsTextField.vAlign = VAlign.TOP;
			pendingCreditsTextField.y = creditsTextField.y + creditsTextField.height / 2;
			addChild(pendingCreditsTextField);

			var messagesTextField : TextField = new TextField(stage.stageWidth, 30 * scaleFactor, "", "QuicksandSmall", 20 * scaleFactor);
			messagesTextField.hAlign = HAlign.CENTER;
			messagesTextField.vAlign = VAlign.BOTTOM;
			messagesTextField.pivotY = messagesTextField.height;
			messagesTextField.y = creditsTextField.y - creditsTextField.height / 2;
			addChild(messagesTextField);

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
					if (row == 3 && column == 3)
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
			turnEndState.addInstance(new ComboSystem(gameState)).withPriority(SystemPriorities.PRE_LOGIC);
			turnEndState.addInstance(new AddPendingCreditsSystem(gameState)).withPriority(SystemPriorities.LOGIC);
			turnEndState.addInstance(new TurnEndStateEndingSystem(stateMachine)).withPriority(SystemPriorities.END);

			engine.addSystem(new BoundsSystem(entityManager), SystemPriorities.LOGIC);
			engine.addSystem(new CountdownSystem(entityManager), SystemPriorities.LOGIC);
			engine.addSystem(new ScriptSystem(), SystemPriorities.LOGIC);
			engine.addSystem(new HudDisplaySystem(creditsTextField, pendingCreditsTextField, messagesTextField, gameState), SystemPriorities.DISPLAY);
			engine.addSystem(new DisplaySystem(boardContainer, scaleFactor, viewTileSize), SystemPriorities.DISPLAY);

			stateMachine.changeState("selecting");

			var tickProvider : ITickProvider = new StarlingFixedTickProvider(Starling.juggler, 0.017);
			tickProvider.add(engine.update);
			tickProvider.start();
		}
	}
}
