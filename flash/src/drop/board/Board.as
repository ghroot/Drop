package drop.board
{
	import drop.*;
	import ash.core.Engine;
	import ash.fsm.EngineState;
	import ash.fsm.EngineStateMachine;
	import ash.integration.starling.StarlingFixedTickProvider;
	import ash.tick.ITickProvider;

	import drop.data.GameState;
	import drop.system.BoundsSystem;
	import drop.system.CascadingStateEndingSystem;
	import drop.system.CountdownSystem;
	import drop.system.DisplaySystem;
	import drop.system.FlySystem;
	import drop.system.LineBlastDetonationSystem;
	import drop.system.LineBlastPulseSystem;
	import drop.system.MatchingSystem;
	import drop.system.MoveSystem;
	import drop.system.SelectControlSystem;
	import drop.system.SelectingStateEndingSystem;
	import drop.system.SpawnerSystem;
	import drop.system.SubmittingStateEndingSystem;
	import drop.system.SystemPriorities;
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

			var entityManager : EntityManager = new EntityManager(engine, boardSize, tileSize);

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

			var engineStateMachine : EngineStateMachine = new EngineStateMachine(engine);

			var selectingState : EngineState = engineStateMachine.createState("selecting");
			selectingState.addInstance(new TouchInputSystem(quad, gameState)).withPriority(SystemPriorities.INPUT);
			selectingState.addInstance(new SelectControlSystem(gameState, boardSize, tileSize)).withPriority(SystemPriorities.CONTROL);
			selectingState.addInstance(new SelectingStateEndingSystem(engineStateMachine, gameState)).withPriority(SystemPriorities.END);

			var submittingState : EngineState = engineStateMachine.createState("submitting");
			submittingState.addInstance(new MatchingSystem()).withPriority(SystemPriorities.POST_LOGIC);
			submittingState.addInstance(new SubmittingStateEndingSystem(engineStateMachine)).withPriority(10);

			var cascadingState : EngineState = engineStateMachine.createState("cascading");
			cascadingState.addInstance(new LineBlastDetonationSystem(entityManager)).withPriority(SystemPriorities.LOGIC);
			cascadingState.addInstance(new LineBlastPulseSystem(tileSize)).withPriority(SystemPriorities.LOGIC);
			cascadingState.addInstance(new SpawnerSystem(tileSize, entityManager)).withPriority(SystemPriorities.LOGIC);
			cascadingState.addInstance(new MoveSystem(boardSize, tileSize)).withPriority(SystemPriorities.LOGIC);
			cascadingState.addInstance(new CascadingStateEndingSystem(engineStateMachine)).withPriority(SystemPriorities.END);

			engine.addSystem(new FlySystem(), SystemPriorities.LOGIC);
			engine.addSystem(new BoundsSystem(entityManager), SystemPriorities.LOGIC);
			engine.addSystem(new CountdownSystem(entityManager), SystemPriorities.LOGIC);
			engine.addSystem(new DisplaySystem(boardContainer), SystemPriorities.DISPLAY);

			engineStateMachine.changeState("selecting");

			var tickProvider : ITickProvider = new StarlingFixedTickProvider(Starling.juggler, 0.017);
			tickProvider.add(engine.update);
			tickProvider.start();
		}
	}
}
