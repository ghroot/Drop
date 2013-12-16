package drop.board
{
	import ash.core.Engine;
	import ash.core.Entity;
	import ash.fsm.EngineState;
	import ash.fsm.EngineStateMachine;
	import ash.integration.starling.StarlingFixedTickProvider;
	import ash.tick.ITickProvider;

	import drop.node.GameNode;
	import drop.node.SpawnerNode;
	import drop.persist.Persister;
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
	import drop.system.PendingCreditsRecordSystem;
	import drop.system.PersistSystem;
	import drop.system.ScoreSynchronizationSystem;
	import drop.system.ScriptSystem;
	import drop.system.SelectControlSystem;
	import drop.system.SelectingStateEndingSystem;
	import drop.system.SpawnerSystem;
	import drop.system.SwapSystem;
	import drop.system.SwappingStateEndingSystem;
	import drop.system.SystemPriorities;
	import drop.system.TouchInputSystem;
	import drop.system.TurnEndStateEndingSystem;
	import drop.system.TurnStartStateEndingSystem;
	import drop.util.DisplayUtils;
	import drop.util.EndlessValueSequence;
	import drop.util.MathUtils;

	import flash.geom.Point;

	import starling.animation.Tween;

	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.utils.AssetManager;
	import starling.utils.Color;
	import starling.utils.HAlign;
	import starling.utils.VAlign;

	public class Board extends Sprite
	{
		private var assets : AssetManager;

		private var boardSize : Point;
		private var tileSize : int;
		private var sceneContainer : SceneContainer;
		private var dragStartPositionY : Number = -1;
		private var engine : Engine;
		private var gameNode : GameNode;
		private var spawnerLevelCost : EndlessValueSequence;
		private var persister : Persister;
		private var selectedSpawnerEntity : Entity;
		private var spawnerUpgradeConfirmationSprite : Sprite;

		public function Board(assets : AssetManager)
		{
			this.assets = assets;

			spawnerLevelCost = new EndlessValueSequence(100, function(previousValue : int, currentValue : int) : int
			{
				return currentValue * 2;
			});

			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}

		private function onAddedToStage(event : Event) : void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

			setupSize();
			setupScene();
			createWorld();

			updateSpawnerButtonLabels();
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
			engine = new Engine();

			var entityManager : EntityManager = new EntityManager(engine, assets, boardSize, tileSize);

			persister = new Persister(engine, entityManager);

			if (persister.hasPersistedData())
			{
				persister.restore();

				updateSpawnerButtonLabels();
			}
			else
			{
				engine.addEntity(entityManager.createGame());

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
			}

			gameNode = engine.getNodeList(GameNode).head;

			var matcher : Matcher = new Matcher(boardSize, tileSize);

			var stateMachine : EngineStateMachine = new EngineStateMachine(engine);

			var turnStartState : EngineState = stateMachine.createState("turnStart");
			turnStartState.addInstance(new PersistSystem(persister)).withPriority(SystemPriorities.LOGIC);
			turnStartState.addInstance(new TurnStartStateEndingSystem(stateMachine)).withPriority(SystemPriorities.END);

			var selectingState : EngineState = stateMachine.createState("selecting");
			selectingState.addInstance(new TouchInputSystem(sceneContainer.touchQuad)).withPriority(SystemPriorities.INPUT);
			selectingState.addInstance(new SelectControlSystem(tileSize)).withPriority(SystemPriorities.CONTROL);
			selectingState.addInstance(new SelectingStateEndingSystem(stateMachine)).withPriority(SystemPriorities.END);

			var swappingState : EngineState = stateMachine.createState("swapping");
			swappingState.addInstance(new SwapSystem()).withPriority(SystemPriorities.LOGIC);
			swappingState.addInstance(new SwappingStateEndingSystem(stateMachine)).withPriority(SystemPriorities.END);

			var matchingState : EngineState = stateMachine.createState("matching");
			matchingState.addInstance(new MatchingSystem(matcher)).withPriority(SystemPriorities.LOGIC);
			matchingState.addInstance(new MatchingStateEndingSystem(stateMachine)).withPriority(SystemPriorities.END);

			var highlightingState : EngineState = stateMachine.createState("highlighting");
			highlightingState.addInstance(new HighlightSystem()).withPriority(SystemPriorities.PRE_LOGIC);
			highlightingState.addInstance(new HighlightDisplaySystem(sceneContainer.overlayContainer, boardSize, tileSize)).withPriority(SystemPriorities.DISPLAY);
			highlightingState.addInstance(new HighlightingStateEndingSystem(stateMachine)).withPriority(SystemPriorities.END);

			var cascadingState : EngineState = stateMachine.createState("cascading");
			cascadingState.addInstance(new LineBlastDetonationSystem(entityManager, boardSize, tileSize)).withPriority(SystemPriorities.LOGIC);
			cascadingState.addInstance(new SpawnerSystem(tileSize, entityManager)).withPriority(SystemPriorities.LOGIC);
			cascadingState.addInstance(new MoveSystem(boardSize, tileSize)).withPriority(SystemPriorities.LOGIC);
			cascadingState.addInstance(new CascadingStateEndingSystem(stateMachine)).withPriority(SystemPriorities.END);

			var turnEndState : EngineState = stateMachine.createState("turnEnd");
			turnEndState.addInstance(new ComboSystem()).withPriority(SystemPriorities.PRE_LOGIC);
			turnEndState.addInstance(new PendingCreditsRecordSystem()).withPriority(SystemPriorities.LOGIC);
			turnEndState.addInstance(new AddPendingCreditsSystem()).withPriority(SystemPriorities.POST_LOGIC);
			turnEndState.addInstance(new TurnEndStateEndingSystem(stateMachine, matcher, entityManager)).withPriority(SystemPriorities.END);

			engine.addSystem(new BoundsSystem(entityManager), SystemPriorities.LOGIC);
			engine.addSystem(new CountdownSystem(entityManager), SystemPriorities.LOGIC);
			engine.addSystem(new ScriptSystem(), SystemPriorities.LOGIC);
			engine.addSystem(new ScoreSynchronizationSystem(spawnerLevelCost), SystemPriorities.LOGIC);
			engine.addSystem(new HudDisplaySystem(sceneContainer), SystemPriorities.DISPLAY);
			engine.addSystem(new DisplaySystem(sceneContainer.boardContainer, tileSize), SystemPriorities.DISPLAY);

			stateMachine.changeState("turnStart");

			var tickProvider : ITickProvider = new StarlingFixedTickProvider(Starling.juggler, 0.017);
			tickProvider.add(engine.update);
			tickProvider.start();
		}

		private function onBottomTouch(event : TouchEvent) : void
		{
			if (gameNode.gameStateComponent.isSelecting)
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
							sceneContainer.boardContainer.y = sceneContainer.boardPosition.y + position.y - dragStartPositionY;
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

					if (touch.phase == TouchPhase.MOVED ||
							touch.phase == TouchPhase.ENDED)
					{
						sceneContainer.touchQuad.touchable = sceneContainer.boardContainer.y == sceneContainer.boardPosition.y;
						sceneContainer.boardContainer.alpha = MathUtils.min(1, (1 - Math.abs(sceneContainer.boardPosition.y - sceneContainer.boardContainer.y) / tileSize) + 0.1);
						sceneContainer.spawnerButtonsContainer.alpha = 1 - sceneContainer.boardContainer.alpha;
						sceneContainer.spawnerButtonsContainer.y = sceneContainer.boardContainer.y - tileSize;

						if (spawnerUpgradeConfirmationSprite != null)
						{
							removeChild(spawnerUpgradeConfirmationSprite);
							spawnerUpgradeConfirmationSprite = null;
						}

						selectedSpawnerEntity = null;
					}
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
					var cost : int = spawnerLevelCost.getValue(spawnerNode.spawnerComponent.spawnerLevel);

					if (spawnerUpgradeConfirmationSprite != null)
					{
						removeChild(spawnerUpgradeConfirmationSprite);
						spawnerUpgradeConfirmationSprite = null;
					}

					if (selectedSpawnerEntity == null ||
							spawnerNode.entity != selectedSpawnerEntity)
					{
						selectedSpawnerEntity = spawnerNode.entity;

						if (gameNode.gameStateComponent.credits >= cost)
						{
							spawnerUpgradeConfirmationSprite = new Sprite();
							spawnerUpgradeConfirmationSprite.x = spawnerButton.x + spawnerButton.width / 2;
							spawnerUpgradeConfirmationSprite.x = Math.max(spawnerUpgradeConfirmationSprite.x, 90);
							spawnerUpgradeConfirmationSprite.x = Math.min(spawnerUpgradeConfirmationSprite.x, stage.stageWidth - 90);
							spawnerUpgradeConfirmationSprite.y = spawnerButton.y + spawnerButton.height + 20;
							var textField : TextField = new TextField(170, 200, "Tap again to upgrade for " + cost, "fontSmall", 20, Color.BLACK);
							textField.hAlign = HAlign.CENTER;
							textField.vAlign = VAlign.TOP;
							spawnerUpgradeConfirmationSprite.addChild(textField);
							DisplayUtils.centerPivotX(spawnerUpgradeConfirmationSprite);
							addChild(spawnerUpgradeConfirmationSprite);
						}
						else
						{
							spawnerUpgradeConfirmationSprite = new Sprite();
							spawnerUpgradeConfirmationSprite.x = spawnerButton.x + spawnerButton.width / 2;
							spawnerUpgradeConfirmationSprite.x = Math.max(spawnerUpgradeConfirmationSprite.x, 75);
							spawnerUpgradeConfirmationSprite.x = Math.min(spawnerUpgradeConfirmationSprite.x, stage.stageWidth - 75);
							spawnerUpgradeConfirmationSprite.y = spawnerButton.y + spawnerButton.height + 20;
							textField = new TextField(140, 200, "Need " + cost + " to upgrade", "fontSmall", 20, Color.BLACK);
							textField.hAlign = HAlign.CENTER;
							textField.vAlign = VAlign.TOP;
							spawnerUpgradeConfirmationSprite.addChild(textField);
							DisplayUtils.centerPivotX(spawnerUpgradeConfirmationSprite);
							addChild(spawnerUpgradeConfirmationSprite);
						}

						var tween : Tween = new Tween(spawnerUpgradeConfirmationSprite, 0.25);
						tween.animate("y", spawnerUpgradeConfirmationSprite.y);
						tween.animate("alpha", 1);
						Starling.juggler.add(tween);
						spawnerUpgradeConfirmationSprite.y += 10;
						spawnerUpgradeConfirmationSprite.alpha = 0;
					}
					else
					{
						if (gameNode.gameStateComponent.credits >= cost)
						{
							gameNode.gameStateComponent.credits -= cost;
							gameNode.gameStateComponent.creditsUpdated.dispatch();

							spawnerNode.spawnerComponent.spawnerLevel++;

							persister.persist();

							updateSpawnerButtonLabels();
						}

						selectedSpawnerEntity = null;
					}
				}
			}
		}

		private function updateSpawnerButtonLabels() : void
		{
			for each (var spawnerButton : Button in sceneContainer.spawnerButtons)
			{
				for (var spawnerNode : SpawnerNode = engine.getNodeList(SpawnerNode).head; spawnerNode; spawnerNode = spawnerNode.next)
				{
					if (spawnerNode.transformComponent.x == spawnerButton.x)
					{
						spawnerButton.text = (spawnerNode.spawnerComponent.spawnerLevel + 1).toString();
					}
				}
			}
		}
	}
}
