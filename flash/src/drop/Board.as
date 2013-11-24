package drop
{
	import ash.core.Engine;
	import ash.fsm.EngineState;
	import ash.fsm.EngineStateMachine;
	import ash.integration.starling.StarlingFixedTickProvider;
	import ash.tick.ITickProvider;

	import drop.data.GameState;
	import drop.system.CascadingStateEndingSystem;
	import drop.system.DisplaySystem;
	import drop.system.MoveSystem;
	import drop.system.RemoveSelectionSystem;
	import drop.system.SelectControlSystem;
	import drop.system.SelectingStateEndingSystem;
	import drop.system.SpawnerSystem;
	import drop.system.SubmittingStateEndingSystem;
	import drop.system.TouchInputSystem;

	import flash.geom.Point;

	import starling.core.Starling;
	import starling.display.Quad;
	import starling.display.Sprite;

	public class Board extends Sprite
	{
		public function Board()
		{
			var boardSize : Point = new Point(7, 8);
			var tileSize : int = 90;

			var quad : Quad = new Quad(640, 960, 0xffffff);
			addChild(quad);

			var boardContainer : Sprite = new Sprite();
			addChild(boardContainer);

			var gameState : GameState = new GameState();

			var engine : Engine = new Engine();

			var creator : Creator = new Creator(tileSize);

			for (var row : int = 0; row < boardSize.y; row++)
			{
				for (var column : int = 0; column < boardSize.x; column++)
				{
					var x : Number = column * tileSize;
					var y : Number = row * tileSize;
					if (row == 0)
					{
						engine.addEntity(creator.createSpawner(x, y));
					}
					if (row == 3 &&
							(column == 1 || column == 5))
					{
						engine.addEntity(creator.createBlocker(x, y));
					}
					else
					{
						engine.addEntity(creator.createTile(x, y));
					}
				}
			}

			var engineStateMachine : EngineStateMachine = new EngineStateMachine(engine);

			var selectingState : EngineState = engineStateMachine.createState("selecting");
			selectingState.addInstance(new TouchInputSystem(quad, gameState)).withPriority(1);
			selectingState.addInstance(new SelectControlSystem(gameState, boardSize, tileSize)).withPriority(2);
			selectingState.addInstance(new SelectingStateEndingSystem(engineStateMachine, gameState)).withPriority(10);

			var submittingState : EngineState = engineStateMachine.createState("submitting");
			submittingState.addInstance(new RemoveSelectionSystem()).withPriority(1);
			submittingState.addInstance(new SubmittingStateEndingSystem(engineStateMachine)).withPriority(10);

			var cascadingState : EngineState = engineStateMachine.createState("cascading");
			cascadingState.addInstance(new SpawnerSystem(tileSize, creator)).withPriority(1);
			cascadingState.addInstance(new MoveSystem(boardSize, tileSize)).withPriority(2);
			cascadingState.addInstance(new CascadingStateEndingSystem(engineStateMachine)).withPriority(10);

			engine.addSystem(new DisplaySystem(boardContainer), 10);

			engineStateMachine.changeState("selecting");

			var tickProvider : ITickProvider = new StarlingFixedTickProvider(Starling.juggler, 0.017);
			tickProvider.add(engine.update);
			tickProvider.start();
		}
	}
}
