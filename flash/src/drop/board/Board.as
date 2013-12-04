package drop.board
{
	import ash.core.Engine;
	import ash.fsm.EngineState;
	import ash.fsm.EngineStateMachine;
	import ash.integration.starling.StarlingFixedTickProvider;
	import ash.tick.ITickProvider;

	import drop.data.GameRules;
	import drop.data.GameState;
	import drop.node.SpawnerNode;
	import drop.scene.SceneContainer;
	import drop.system.AddPendingCreditsSystem;
	import drop.system.BoundsSystem;
	import drop.system.CascadingStateEndingSystem;
	import drop.system.ComboSystem;
	import drop.system.CountdownSystem;
	import drop.system.DisplaySystem;
	import drop.system.HighlightDisplaySystem;
	import drop.system.HighlightSystem;
	import drop.system.HighlightingStateEndingSystem;
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
	import drop.util.MathUtils;

	import flash.geom.Point;

	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.utils.AssetManager;

	public class Board extends Sprite
	{
		private var assets : AssetManager;

		private var engine : Engine;
		private var gameState : GameState;

		private var boardSize : Point;
		private var tileSize : int;
		private var sceneContainer : SceneContainer;
		private var dragStartPositionY : Number = -1;

		public function Board(assets : AssetManager)
		{
			this.assets = assets;

			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}

		private function onAddedToStage(event : Event) : void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

			setupSize();
			setupScene();
			createWorld();
		}

		private function setupSize() : void
		{
			boardSize = new Point(7, 7);
			tileSize = 44;
		}

		private function setupScene() : void
		{
			sceneContainer = new SceneContainer(assets, boardSize, tileSize);
			addChild(sceneContainer);

			sceneContainer.bottomTouchQuad.addEventListener(TouchEvent.TOUCH, onBottomTouch);

			for each (var spawnerButton : Button in sceneContainer.spawnerButtons)
			{
				spawnerButton.addEventListener(Event.TRIGGERED, onSpawnerButtonTriggered);
			}
		}

		private function createWorld() : void
		{
			gameState = new GameState();
			var gameRules : GameRules = new GameRules(gameState);

			engine = new Engine();

			var entityManager : EntityManager = new EntityManager(engine, assets, boardSize, tileSize);

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
			selectingState.addInstance(new TouchInputSystem(sceneContainer.touchQuad, gameState)).withPriority(SystemPriorities.INPUT);
			selectingState.addInstance(new SelectControlSystem(gameState, tileSize)).withPriority(SystemPriorities.CONTROL);
			selectingState.addInstance(new SelectingStateEndingSystem(stateMachine, gameState)).withPriority(SystemPriorities.END);

			var swappingState : EngineState = stateMachine.createState("swapping");
			swappingState.addInstance(new SwapSystem(gameState)).withPriority(SystemPriorities.LOGIC);
			swappingState.addInstance(new SwappingStateEndingSystem(stateMachine, gameState)).withPriority(SystemPriorities.END);

			var matchingState : EngineState = stateMachine.createState("matching");
			matchingState.addInstance(new MatchingSystem(matcher, gameState, gameRules)).withPriority(SystemPriorities.LOGIC);
			matchingState.addInstance(new MatchingStateEndingSystem(stateMachine, gameState)).withPriority(SystemPriorities.END);

			var highlightingState : EngineState = stateMachine.createState("highlighting");
			highlightingState.addInstance(new HighlightSystem(gameState)).withPriority(SystemPriorities.PRE_LOGIC);
			highlightingState.addInstance(new HighlightDisplaySystem(sceneContainer.overlayContainer, boardSize, tileSize, gameState)).withPriority(SystemPriorities.DISPLAY);
			highlightingState.addInstance(new HighlightingStateEndingSystem(stateMachine)).withPriority(SystemPriorities.END);

			var cascadingState : EngineState = stateMachine.createState("cascading");
			cascadingState.addInstance(new LineBlastDetonationSystem(entityManager, boardSize, tileSize, gameRules)).withPriority(SystemPriorities.LOGIC);
			cascadingState.addInstance(new SpawnerSystem(tileSize, entityManager)).withPriority(SystemPriorities.LOGIC);
			cascadingState.addInstance(new MoveSystem(boardSize, tileSize)).withPriority(SystemPriorities.LOGIC);
			cascadingState.addInstance(new CascadingStateEndingSystem(stateMachine)).withPriority(SystemPriorities.END);

			var turnEndState : EngineState = stateMachine.createState("turnEnd");
			turnEndState.addInstance(new ComboSystem(gameState, gameRules)).withPriority(SystemPriorities.PRE_LOGIC);
			turnEndState.addInstance(new AddPendingCreditsSystem(gameRules)).withPriority(SystemPriorities.LOGIC);
			turnEndState.addInstance(new TurnEndStateEndingSystem(stateMachine)).withPriority(SystemPriorities.END);

			engine.addSystem(new BoundsSystem(entityManager), SystemPriorities.LOGIC);
			engine.addSystem(new CountdownSystem(entityManager), SystemPriorities.LOGIC);
			engine.addSystem(new ScriptSystem(), SystemPriorities.LOGIC);
			engine.addSystem(new HudDisplaySystem(sceneContainer.creditsTextField, sceneContainer.pendingCreditsTextField, gameState), SystemPriorities.DISPLAY);
			engine.addSystem(new DisplaySystem(sceneContainer.boardContainer, tileSize), SystemPriorities.DISPLAY);

			stateMachine.changeState("selecting");

			var tickProvider : ITickProvider = new StarlingFixedTickProvider(Starling.juggler, 0.017);
			tickProvider.add(engine.update);
			tickProvider.start();
		}

		private function onBottomTouch(event : TouchEvent) : void
		{
			if (gameState.isSelecting)
			{
				var touch : Touch = event.getTouch(event.target as DisplayObject);
				if (touch != null)
				{
					if (touch.phase == TouchPhase.MOVED)
					{
						var position : Point = touch.getLocation(event.target as DisplayObject);
						if (dragStartPositionY == -1)
						{
							if (sceneContainer.boardContainer.y == sceneContainer.boardPosition.y)
							{
								dragStartPositionY = position.y;
							}
							else
							{
								dragStartPositionY = position.y - tileSize;
							}
						}
						else
						{
							sceneContainer.boardContainer.y = position.y - dragStartPositionY;
							sceneContainer.boardContainer.y = MathUtils.max(sceneContainer.boardContainer.y, sceneContainer.boardPosition.y);
							sceneContainer.boardContainer.y = MathUtils.min(sceneContainer.boardContainer.y, sceneContainer.boardPosition.y + tileSize);
						}
					}
					else if (touch.phase == TouchPhase.ENDED)
					{
						if (sceneContainer.boardContainer.y < sceneContainer.boardPosition.y + tileSize / 2)
						{
							sceneContainer.boardContainer.y = sceneContainer.boardPosition.y;
						}
						else
						{
							sceneContainer.boardContainer.y = sceneContainer.boardPosition.y + tileSize;
						}

						dragStartPositionY = -1;
					}

					sceneContainer.touchQuad.touchable = sceneContainer.boardContainer.y == sceneContainer.boardPosition.y;
					sceneContainer.boardContainer.alpha = MathUtils.min(1, (1 - Math.abs(sceneContainer.boardPosition.y - sceneContainer.boardContainer.y) / tileSize) + 0.1);
					sceneContainer.spawnerButtonsContainer.alpha = 1 - sceneContainer.boardContainer.alpha;
					sceneContainer.spawnerButtonsContainer.y = sceneContainer.boardContainer.y - tileSize;
				}
			}
		}

		private function onSpawnerButtonTriggered(event : Event) : void
		{
			var spawnerButton : Button = event.target as Button;
			for (var spawnerNode : SpawnerNode = engine.getNodeList(SpawnerNode).head; spawnerNode; spawnerNode = spawnerNode.next)
			{
				if (spawnerNode.transformComponent.x == spawnerButton.x)
				{
					if (spawnerNode.spawnerComponent.spawnerLevel.level < 4 &&
							gameState.credits >= getCostForSpawnerLevelUpgrade(spawnerNode))
					{
						gameState.credits -= getCostForSpawnerLevelUpgrade(spawnerNode);
						gameState.creditsUpdated.dispatch(gameState.credits);

						spawnerNode.spawnerComponent.spawnerLevel.level++;

						spawnerButton.text = spawnerNode.spawnerComponent.spawnerLevel.level.toString();
					}
				}
			}
		}

		private function getCostForSpawnerLevelUpgrade(spawnerNode : SpawnerNode) : int
		{
			switch (spawnerNode.spawnerComponent.spawnerLevel.level)
			{
				case 1:
					return 100;
				case 2:
					return 1000;
				case 3:
					return 5000;
				default:
					return 0;
			}
		}
	}
}
