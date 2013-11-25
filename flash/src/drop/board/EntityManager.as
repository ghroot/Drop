package drop.board
{
	import ash.core.Engine;
	import ash.core.Entity;
	import ash.fsm.EntityState;
	import ash.fsm.EntityStateMachine;
	import ash.fsm.IComponentProvider;
	import ash.tools.ComponentPool;

	import drop.component.BlockComponent;
	import drop.component.BoundsComponent;
	import drop.component.CountdownComponent;
	import drop.component.DisplayComponent;
	import drop.component.FlyComponent;
	import drop.component.LineBlastComponent;
	import drop.component.LineBlastPulseComponent;
	import drop.component.LineBlastTargetComponent;
	import drop.component.MatchComponent;
	import drop.component.MoveComponent;
	import drop.component.SelectComponent;
	import drop.component.SpawnerComponent;
	import drop.component.StateComponent;
	import drop.component.TransformComponent;

	import flash.geom.Point;

	import starling.display.Quad;

	public class EntityManager
	{
		private var engine : Engine;
		private var boardSize : Point;
		private var tileSize : int;

		private var colors : Vector.<int>;

		public function EntityManager(engine : Engine, boardSize : Point, tileSize : int)
		{
			this.engine = engine;
			this.boardSize = boardSize;
			this.tileSize = tileSize;

			colors = new Vector.<int>();
			for (var i : int = 0; i < 5; i++)
			{
				colors[colors.length] = Math.random() * 16777215;
			}
		}

		public function createTile(x : Number, y : Number) : Entity
		{
			var entity : Entity = new Entity();

			var stateMachine : EntityStateMachine = new EntityStateMachine(entity);

			var color : int = colors[Math.floor(Math.random() * colors.length)];

			var idleState : EntityState = stateMachine.createState("idle");
			idleState.add(LineBlastTargetComponent).withInstance(LineBlastTargetComponent.create());
			var idleQuad : Quad = new Quad(tileSize, tileSize, color);
			idleQuad.touchable = false;
			idleState.add(DisplayComponent).withInstance(DisplayComponent.create().withDisplayObject(idleQuad));

			var selectedState : EntityState = stateMachine.createState("selected");
			var selectedQuad : Quad = new Quad(tileSize - 10, tileSize - 10, color);
			selectedQuad.pivotX = selectedQuad.pivotY = -5;
			selectedQuad.touchable = false;
			selectedState.add(DisplayComponent).withInstance(DisplayComponent.create().withDisplayObject(selectedQuad));

			var matchedState : EntityState = stateMachine.createState("matched");
			matchedState.add(CountdownComponent).withInstance(CountdownComponent.create());

			var destroyedByLineBlastState : EntityState = stateMachine.createState("destroyedByLineBlast");
			destroyedByLineBlastState.add(CountdownComponent).withInstance(CountdownComponent.create().withTime(0.6));

			entity.add(TransformComponent.create().withX(x).withY(y));
			entity.add(BlockComponent.create());
			entity.add(MoveComponent.create());
			entity.add(SelectComponent.create());
			entity.add(MatchComponent.create().withColor(color));
			entity.add(StateComponent.create().withStateMachine(stateMachine));

			stateMachine.changeState("idle");

			return entity;
		}

		public function createLineBlast(x : Number, y : Number) : Entity
		{
			var entity : Entity = new Entity();

			var stateMachine : EntityStateMachine = new EntityStateMachine(entity);

			var triggeredLineBlastComponent : LineBlastComponent = LineBlastComponent.create().withIsTriggered(true);
			var nonTriggeredLineBlastComponent : LineBlastComponent = LineBlastComponent.create();

			var color : int = colors[Math.floor(Math.random() * colors.length)];

			var idleState : EntityState = stateMachine.createState("idle");
			idleState.add(LineBlastComponent).withInstance(nonTriggeredLineBlastComponent);
			idleState.add(LineBlastTargetComponent).withInstance(LineBlastTargetComponent.create());
			var idleQuad : Quad = new Quad(tileSize, tileSize, color);
			idleQuad.touchable = false;
			idleState.add(DisplayComponent).withInstance(DisplayComponent.create().withDisplayObject(idleQuad));

			var selectedState : EntityState = stateMachine.createState("selected");
			selectedState.add(LineBlastComponent).withInstance(nonTriggeredLineBlastComponent);
			var selectedQuad : Quad = new Quad(tileSize - 10, tileSize - 10, color);
			selectedQuad.pivotX = selectedQuad.pivotY = -5;
			selectedQuad.touchable = false;
			selectedState.add(DisplayComponent).withInstance(DisplayComponent.create().withDisplayObject(selectedQuad));

			var matchedState : EntityState = stateMachine.createState("matched");
			matchedState.add(CountdownComponent).withInstance(CountdownComponent.create().withStateToChangeTo("triggered"));

			var triggeredState : EntityState = stateMachine.createState("triggered");
			triggeredState.add(LineBlastComponent).withInstance(triggeredLineBlastComponent);

			var detonatedState : EntityState = stateMachine.createState("detonated");
			detonatedState.add(CountdownComponent).withInstance(CountdownComponent.create().withTime(0.6));

			var destroyedByLineBlastState : EntityState = stateMachine.createState("destroyedByLineBlast");
			destroyedByLineBlastState.add(CountdownComponent).withInstance(CountdownComponent.create().withStateToChangeTo("triggered"));

			entity.add(TransformComponent.create().withX(x).withY(y));
			entity.add(BlockComponent.create());
			entity.add(MoveComponent.create());
			entity.add(SelectComponent.create());
			entity.add(MatchComponent.create().withColor(color));
			entity.add(StateComponent.create().withStateMachine(stateMachine));

			stateMachine.changeState("idle");

			return entity;
		}

		public function createLineBlastPulse(x : Number, y : Number, blastDirectionX : int, blastDirectionY : int) : Entity
		{
			var entity : Entity = new Entity();

			var quad : Quad = new Quad(tileSize / 2, tileSize / 2, 0xcccccc);
			quad.pivotX = quad.pivotY = -tileSize / 4;
			quad.touchable = false;
			entity.add(DisplayComponent.create().withDisplayObject(quad));

			entity.add(FlyComponent.create().withVelocityX(extend(blastDirectionX, 16)).withVelocityY(extend(blastDirectionY, 16)));
			entity.add(BoundsComponent.create().withWidth(boardSize.x * tileSize).withHeight(boardSize.y * tileSize));
			entity.add(TransformComponent.create().withX(x + cap(blastDirectionX, 30)).withY(y + cap(blastDirectionY, 30)));
			entity.add(LineBlastPulseComponent.create());

			return entity;
		}

		private function cap(value : Number, cap : Number) : Number
		{
			if (value < 0)
			{
				return Math.max(value, -cap);
			}
			else
			{
				return Math.min(value, cap);
			}
		}

		private function extend(value : Number, length : Number) : Number
		{
			if (value < 0)
			{
				return -length;
			}
			else if (value > 0)
			{
				return length;
			}
			else
			{
				return 0;
			}
		}

		public function createSpawner(x : Number, y : Number) : Entity
		{
			var entity : Entity = new Entity();

			entity.add(new SpawnerComponent());
			entity.add(TransformComponent.create().withX(x).withY(y));

			return entity;
		}

		public function createBlocker(x : Number, y : Number) : Entity
		{
			var entity : Entity = new Entity();

			entity.add(new BlockComponent());
			entity.add(TransformComponent.create().withX(x).withY(y));

			return entity;
		}

		public function destroyEntity(entity : Entity) : void
		{
			engine.removeEntity(entity);

			var components : Vector.<Object> = new Vector.<Object>();

			for each (var component : Object in entity.components)
			{
				components[components.length] = component;
			}

			var stateComponent : StateComponent = entity.get(StateComponent);
			if (stateComponent != null)
			{
				for each (var state : EntityState in stateComponent.stateMachine.states)
				{
					for each (var provider : IComponentProvider in state.providers)
					{
						component = provider.getComponent();
						if (components.indexOf(component) == -1)
						{
							components[components.length] = component;
						}
					}
				}
			}

			for each (component in components)
			{
				component.reset();
				ComponentPool.dispose(component);
			}
		}
	}
}