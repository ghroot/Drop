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

	import feathers.controls.Button;
	import feathers.controls.LayoutGroup;
	import feathers.controls.Screen;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;

	import flash.geom.Point;

	import org.osflash.signals.Signal;

	import starling.core.Starling;
	import starling.display.Quad;
	import starling.display.Sprite;

	import starling.events.Event;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;

	public class BoardScreen extends Screen
	{
		private var scaleFactor : Number;
		private var sharedState : Object;

		public var onStats : Signal = new Signal(BoardScreen);

		private var gameState : GameState;

		public function BoardScreen(scaleFactor : Number, sharedState : Object)
		{
			this.scaleFactor = scaleFactor;
			this.sharedState = sharedState;

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

			var group : LayoutGroup = new LayoutGroup();
			group.setSize(stage.stageWidth, stage.stageHeight);
			group.layout = new AnchorLayout();
			addChild(group);

			var statsButton : Button = new Button();
			statsButton.label = "Stats";
			statsButton.addEventListener(Event.TRIGGERED, onStatusButtonTriggered);
			group.addChild(statsButton);

			var layoutData : AnchorLayoutData = new AnchorLayoutData();
			layoutData.right = 2;
			layoutData.bottom = 2;
			statsButton.layoutData = layoutData;

			gameState = new GameState();

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

			engine.addSystem(new BoundsSystem(entityManager), SystemPriorities.LOGIC);
			engine.addSystem(new CountdownSystem(entityManager), SystemPriorities.LOGIC);
			engine.addSystem(new ScriptSystem(), SystemPriorities.LOGIC);
			engine.addSystem(new HudDisplaySystem(textField, statusTextField, gameState), SystemPriorities.DISPLAY);
			engine.addSystem(new DisplaySystem(boardContainer, scaleFactor, viewTileSize), SystemPriorities.DISPLAY);

			stateMachine.changeState("selecting");

			var tickProvider : ITickProvider = new StarlingFixedTickProvider(Starling.juggler, 0.017);
			tickProvider.add(engine.update);
			tickProvider.add(updateSharedState);
			tickProvider.start();
		}

		private function updateSharedState(time : Number) : void
		{
			sharedState["matchPatternLevels"] = gameState.matchPatternLevels;
		}

		private function onStatusButtonTriggered(event : Event) : void
		{
			onStats.dispatch(this);
		}
	}
}
