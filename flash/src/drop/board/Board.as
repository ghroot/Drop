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
	import drop.util.DisplayUtils;
	import drop.util.MathUtils;

	import flash.geom.Point;

	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.Button;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.BitmapFont;
	import starling.text.TextField;
	import starling.textures.RenderTexture;
	import starling.utils.AssetManager;
	import starling.utils.Color;
	import starling.utils.HAlign;
	import starling.utils.VAlign;

	public class Board extends Sprite
	{
		private var assets : AssetManager;

		private var engine : Engine;
		private var gameState : GameState;

		private var boardSize : Point;
		private var tileSize : int;
		private var boardPosition : Point;
		private var boardContainer : Sprite;
		private var touchQuad : Quad;
		private var spawnerButtonsContainer : Sprite;
		private var dragStartPositionY : Number = -1;

		public function Board(assets : AssetManager)
		{
			this.assets = assets;

			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}

		private function onAddedToStage(event : Event) : void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

			boardSize = new Point(7, 7);
			tileSize = 44;

			var padding : Number = (stage.stageWidth - boardSize.x * tileSize) / 2;
			boardPosition = new Point(padding, padding);

			var backgroundImage : Image = new Image(assets.getTexture("background"));
			DisplayUtils.centerPivot(backgroundImage);
			backgroundImage.x = stage.stageWidth / 2;
			backgroundImage.y = stage.stageHeight / 2;
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

			spawnerButtonsContainer = new Sprite();
			spawnerButtonsContainer.x = padding;
			spawnerButtonsContainer.y = boardContainer.y - tileSize;
			for (column = 0; column < boardSize.x; column++)
			{
				var renderTexture : RenderTexture = new RenderTexture(tileSize, tileSize);
				var image : Image = new Image(assets.getTexture("spawner"));
				renderTexture.draw(image);
				var spawnerLevelTextField : TextField = new TextField(tileSize, tileSize, "1", "fontSmall", 20, Color.WHITE);
				spawnerLevelTextField.hAlign = HAlign.CENTER;
				spawnerLevelTextField.vAlign = VAlign.CENTER;
				renderTexture.draw(spawnerLevelTextField);
				var spawnerButton : Button = new Button(renderTexture);
				spawnerButton.x = column * tileSize;
				spawnerButton.addEventListener(Event.TRIGGERED, onSpawnerButtonTriggered);
				spawnerButtonsContainer.addChild(spawnerButton);
			}
			spawnerButtonsContainer.alpha = 0;
			addChild(spawnerButtonsContainer);

			var overlayContainer : Sprite = new Sprite();
			overlayContainer.x = boardPosition.x;
			overlayContainer.y = boardPosition.y;
			overlayContainer.touchable = false;
			addChild(overlayContainer);

			var creditsTextField : TextField = new TextField(stage.stageWidth, 70, "0", "font", 60);
			creditsTextField.hAlign = HAlign.CENTER;
			creditsTextField.vAlign = VAlign.CENTER;
			DisplayUtils.centerPivot(creditsTextField);
			creditsTextField.x = stage.stageWidth / 2;
			creditsTextField.y = boardPosition.y + boardSize.y * tileSize + (stage.stageHeight - boardSize.y * tileSize - boardPosition.y) / 2;
			creditsTextField.touchable = false;
			addChild(creditsTextField);

			var pendingCreditsTextField : TextField = new TextField(stage.stageWidth, 30, "0", "fontSmall", 20);
			pendingCreditsTextField.hAlign = HAlign.CENTER;
			pendingCreditsTextField.vAlign = VAlign.TOP;
			pendingCreditsTextField.y = creditsTextField.y + 26;
			pendingCreditsTextField.touchable = false;
			addChild(pendingCreditsTextField);

			var bottomTouchQuad : Quad = new Quad(stage.stageWidth, stage.stageHeight - boardSize.y * tileSize - padding);
			bottomTouchQuad.y = boardPosition.y + boardSize.y * tileSize + padding;
			bottomTouchQuad.alpha = 0;
			bottomTouchQuad.blendMode = BlendMode.NONE;
			bottomTouchQuad.addEventListener(TouchEvent.TOUCH, onBottomTouch);
			addChild(bottomTouchQuad);

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
			selectingState.addInstance(new TouchInputSystem(touchQuad, gameState)).withPriority(SystemPriorities.INPUT);
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
			highlightingState.addInstance(new HighlightDisplaySystem(overlayContainer, boardSize, tileSize, gameState)).withPriority(SystemPriorities.DISPLAY);
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
			engine.addSystem(new HudDisplaySystem(creditsTextField, pendingCreditsTextField, gameState), SystemPriorities.DISPLAY);
			engine.addSystem(new DisplaySystem(boardContainer, tileSize), SystemPriorities.DISPLAY);

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
							if (boardContainer.y == boardPosition.y)
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
							boardContainer.y = position.y - dragStartPositionY;
							boardContainer.y = MathUtils.max(boardContainer.y, boardPosition.y);
							boardContainer.y = MathUtils.min(boardContainer.y, boardPosition.y + tileSize);
						}
					}
					else if (touch.phase == TouchPhase.ENDED)
					{
						if (boardContainer.y < boardPosition.y + tileSize / 2)
						{
							boardContainer.y = boardPosition.y;
						}
						else
						{
							boardContainer.y = boardPosition.y + tileSize;
						}

						dragStartPositionY = -1;
					}

					touchQuad.touchable = boardContainer.y == boardPosition.y;
					boardContainer.alpha = MathUtils.min(1, (1 - Math.abs(boardPosition.y - boardContainer.y) / tileSize) + 0.1);
					spawnerButtonsContainer.alpha = 1 - boardContainer.alpha;
					spawnerButtonsContainer.y = boardContainer.y - tileSize;
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

						var renderTexture : RenderTexture = new RenderTexture(tileSize, tileSize - 2);
						var buttonQuad : Quad = new Quad(tileSize - 2, tileSize - 2, Color.BLACK);
						buttonQuad.x = buttonQuad.y = 1;
						renderTexture.draw(buttonQuad);
						var spawnerLevelTextField : TextField = new TextField(tileSize, tileSize, spawnerNode.spawnerComponent.spawnerLevel.level.toString(), "fontSmall", 20, Color.WHITE);
						spawnerLevelTextField.hAlign = HAlign.CENTER;
						spawnerLevelTextField.vAlign = VAlign.CENTER;
						renderTexture.draw(spawnerLevelTextField);
						spawnerButton.upState = spawnerButton.downState = renderTexture;
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
