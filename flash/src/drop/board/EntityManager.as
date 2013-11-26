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
	import drop.component.script.ScaleScript;
	import drop.component.script.ScriptComponent;
	import drop.util.DisplayUtils;

	import flash.geom.Point;

	import starling.display.Quad;
	import starling.display.Sprite;

	public class EntityManager
	{
		private var engine : Engine;
		private var boardSize : Point;
		private var modelTileSize : int;
		private var viewTileSize : int;

		private var colors : Vector.<int>;

		public function EntityManager(engine : Engine, boardSize : Point, modelTileSize : int, viewTileSize : int)
		{
			this.engine = engine;
			this.boardSize = boardSize;
			this.modelTileSize = modelTileSize;
			this.viewTileSize = viewTileSize;

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
			var quad : Quad = new Quad(viewTileSize, viewTileSize, color);
			DisplayUtils.centerPivot(quad);
			quad.touchable = false;

			var transformComponent : TransformComponent = TransformComponent.create().withX(x).withY(y);
			var selectComponent : SelectComponent = SelectComponent.create();
			var displayComponent : DisplayComponent = DisplayComponent.create().withDisplayObject(quad);

			var idleState : EntityState = stateMachine.createState("idle");
			idleState.add(LineBlastTargetComponent).withInstance(LineBlastTargetComponent.create());
			idleState.add(SelectComponent).withInstance(selectComponent);
			idleState.add(DisplayComponent).withInstance(displayComponent);

			var selectedState : EntityState = stateMachine.createState("selected");
			selectedState.add(ScriptComponent).withInstance(ScriptComponent.create().withScript(new ScaleScript(transformComponent, 0.75)));
			selectedState.add(SelectComponent).withInstance(selectComponent);
			selectedState.add(DisplayComponent).withInstance(displayComponent);

			var matchedState : EntityState = stateMachine.createState("matched");
			matchedState.add(ScriptComponent).withInstance(ScriptComponent.create().withScript(new ScaleScript(transformComponent, 0, 0.4)));
			matchedState.add(DisplayComponent).withInstance(displayComponent);
			matchedState.add(CountdownComponent).withInstance(CountdownComponent.create().withTime(0.4));

			var destroyedByLineBlastState : EntityState = stateMachine.createState("destroyedByLineBlast");
			destroyedByLineBlastState.add(CountdownComponent).withInstance(CountdownComponent.create().withTime(0.6));

			entity.add(transformComponent);
			entity.add(BlockComponent.create());
			entity.add(MoveComponent.create());
			entity.add(MatchComponent.create().withColor(color));
			entity.add(StateComponent.create().withStateMachine(stateMachine));

			stateMachine.changeState("idle");

			return entity;
		}

		public function createLineBlast(x : Number, y : Number) : Entity
		{
			var entity : Entity = new Entity();

			var stateMachine : EntityStateMachine = new EntityStateMachine(entity);

			var color : int = colors[Math.floor(Math.random() * colors.length)];
			var sprite : Sprite = new Sprite();
			var quad : Quad = new Quad(viewTileSize, viewTileSize, color);
			sprite.addChild(quad);
			var smallQuad : Quad = new Quad(viewTileSize / 4, viewTileSize / 4, 0xffffff);
			smallQuad.x = smallQuad.y = 1.5 * viewTileSize / 4;
			sprite.addChild(smallQuad);
			DisplayUtils.centerPivot(sprite);
			sprite.touchable = false;

			var transformComponent : TransformComponent = TransformComponent.create().withX(x).withY(y);
			var selectComponent : SelectComponent = SelectComponent.create();
			var displayComponent : DisplayComponent = DisplayComponent.create().withDisplayObject(sprite);
			var triggeredLineBlastComponent : LineBlastComponent = LineBlastComponent.create().withIsTriggered(true);
			var nonTriggeredLineBlastComponent : LineBlastComponent = LineBlastComponent.create();

			var idleState : EntityState = stateMachine.createState("idle");
			idleState.add(LineBlastComponent).withInstance(nonTriggeredLineBlastComponent);
			idleState.add(LineBlastTargetComponent).withInstance(LineBlastTargetComponent.create());
			idleState.add(SelectComponent).withInstance(selectComponent);
			idleState.add(DisplayComponent).withInstance(displayComponent);

			var selectedState : EntityState = stateMachine.createState("selected");
			selectedState.add(ScriptComponent).withInstance(ScriptComponent.create().withScript(new ScaleScript(transformComponent, 0.75)));
			selectedState.add(SelectComponent).withInstance(selectComponent);
			selectedState.add(LineBlastComponent).withInstance(nonTriggeredLineBlastComponent);
			selectedState.add(DisplayComponent).withInstance(displayComponent);

			var matchedState : EntityState = stateMachine.createState("matched");
			matchedState.add(ScriptComponent).withInstance(ScriptComponent.create().withScript(new ScaleScript(transformComponent, 0, 0.4)));
			matchedState.add(DisplayComponent).withInstance(displayComponent);
			matchedState.add(CountdownComponent).withInstance(CountdownComponent.create().withTime(0.4).withStateToChangeTo("triggered"));

			var triggeredState : EntityState = stateMachine.createState("triggered");
			triggeredState.add(LineBlastComponent).withInstance(triggeredLineBlastComponent);

			var detonatedState : EntityState = stateMachine.createState("detonated");
			detonatedState.add(CountdownComponent).withInstance(CountdownComponent.create().withTime(0.6));

			var destroyedByLineBlastState : EntityState = stateMachine.createState("destroyedByLineBlast");
			destroyedByLineBlastState.add(CountdownComponent).withInstance(CountdownComponent.create().withStateToChangeTo("triggered"));

			entity.add(transformComponent);
			entity.add(BlockComponent.create());
			entity.add(MoveComponent.create());
			entity.add(MatchComponent.create().withColor(color));
			entity.add(StateComponent.create().withStateMachine(stateMachine));

			stateMachine.changeState("idle");

			return entity;
		}

		public function createLineBlastPulse(x : Number, y : Number, blastDirectionX : int, blastDirectionY : int) : Entity
		{
			var entity : Entity = new Entity();

			var quad : Quad = new Quad(viewTileSize / 3, viewTileSize / 3, 0x000000);
			DisplayUtils.centerPivot(quad);
			quad.touchable = false;
			entity.add(DisplayComponent.create().withDisplayObject(quad));

			entity.add(FlyComponent.create().withVelocityX(extend(blastDirectionX, 8)).withVelocityY(extend(blastDirectionY, 8)));
			entity.add(BoundsComponent.create().withWidth(boardSize.x * modelTileSize).withHeight(boardSize.y * modelTileSize));
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