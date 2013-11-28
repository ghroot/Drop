package drop.board
{
	import ash.core.Engine;
	import ash.core.Entity;
	import ash.fsm.EntityState;
	import ash.fsm.EntityStateMachine;
	import ash.fsm.IComponentProvider;
	import ash.tools.ComponentPool;

	import drop.component.BlockComponent;
	import drop.component.CountdownComponent;
	import drop.component.DisplayComponent;
	import drop.component.LineBlastComponent;
	import drop.component.LineBlastTargetComponent;
	import drop.component.MatchComponent;
	import drop.component.MoveComponent;
	import drop.component.SelectComponent;
	import drop.component.SpawnerComponent;
	import drop.component.StateComponent;
	import drop.component.TransformComponent;
	import drop.component.script.AlphaScript;
	import drop.component.script.ScaleScript;
	import drop.component.script.ScriptComponent;
	import drop.component.script.TweenScript;
	import drop.util.DisplayUtils;

	import flash.geom.Point;

	import starling.animation.Tween;
	import starling.display.Quad;
	import starling.display.Sprite;

	public class EntityManager
	{
		private var engine : Engine;
		private var boardSize : Point;
		private var modelTileSize : int;
		private var viewTileSize : int;
		private var scaleFactor : Number;

		private var colors : Vector.<int>;

		public function EntityManager(engine : Engine, boardSize : Point, modelTileSize : int, viewTileSize : int, scaleFactor : Number)
		{
			this.engine = engine;
			this.boardSize = boardSize;
			this.modelTileSize = modelTileSize;
			this.viewTileSize = viewTileSize;
			this.scaleFactor = scaleFactor;

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
			idleState.add(MoveComponent).withInstance(MoveComponent.create());
			idleState.add(SelectComponent).withInstance(selectComponent);
			idleState.add(DisplayComponent).withInstance(displayComponent);

			var selectedState : EntityState = stateMachine.createState("selected");
			selectedState.add(ScriptComponent).withInstance(ScriptComponent.create().withScript(new ScaleScript(transformComponent, 0.75, 0.05, true)));
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
			idleState.add(MoveComponent).withInstance(MoveComponent.create());
			idleState.add(DisplayComponent).withInstance(displayComponent);

			var selectedState : EntityState = stateMachine.createState("selected");
			selectedState.add(ScriptComponent).withInstance(ScriptComponent.create().withScript(new ScaleScript(transformComponent, 0.75, 0.05, true)));
			selectedState.add(SelectComponent).withInstance(selectComponent);
			selectedState.add(LineBlastComponent).withInstance(nonTriggeredLineBlastComponent);
			selectedState.add(DisplayComponent).withInstance(displayComponent);

			var matchedState : EntityState = stateMachine.createState("matched");
			matchedState.add(ScriptComponent).withInstance(ScriptComponent.create()
					.withScript(new AlphaScript(displayComponent, 0.2, 0.6))
					.withScript(new ScaleScript(transformComponent, 0.5, 0.6)));
			matchedState.add(DisplayComponent).withInstance(displayComponent);
			matchedState.add(CountdownComponent).withInstance(CountdownComponent.create().withTime(0.5).withStateToChangeTo("triggered"));

			var triggeredState : EntityState = stateMachine.createState("triggered");
			triggeredState.add(LineBlastComponent).withInstance(triggeredLineBlastComponent);

			var destroyedByLineBlastState : EntityState = stateMachine.createState("destroyedByLineBlast");
			destroyedByLineBlastState.add(ScriptComponent).withInstance(ScriptComponent.create()
					.withScript(new AlphaScript(displayComponent, 0.2, 0.6))
					.withScript(new ScaleScript(transformComponent, 0.5, 0.6)));
			destroyedByLineBlastState.add(DisplayComponent).withInstance(displayComponent);
			destroyedByLineBlastState.add(CountdownComponent).withInstance(CountdownComponent.create().withTime(0.5).withStateToChangeTo("triggered"));

			entity.add(transformComponent);
			entity.add(BlockComponent.create());
			entity.add(MatchComponent.create().withColor(color));
			entity.add(StateComponent.create().withStateMachine(stateMachine));

			stateMachine.changeState("idle");

			return entity;
		}

		public function createLineBlastPulse(x : Number, y : Number, color : int) : Entity
		{
			var entity : Entity = new Entity();

			var fadedHorizontalQuad : Quad = new Quad(boardSize.x * viewTileSize, 8 * scaleFactor, color);
			fadedHorizontalQuad.alpha = 0.2;
			fadedHorizontalQuad.pivotX = (x / modelTileSize * viewTileSize) + viewTileSize / 2;
			DisplayUtils.centerPivotY(fadedHorizontalQuad);

			var horizontalQuad : Quad = new Quad(boardSize.x * viewTileSize, 2 * scaleFactor, color);
			horizontalQuad.pivotX = (x / modelTileSize * viewTileSize) + viewTileSize / 2;
			DisplayUtils.centerPivotY(horizontalQuad);

			var fadedVerticalQuad : Quad = new Quad(8 * scaleFactor, boardSize.y * viewTileSize, color);
			fadedVerticalQuad.alpha = 0.3;
			fadedVerticalQuad.pivotY = (y / modelTileSize * viewTileSize) + viewTileSize / 2;
			DisplayUtils.centerPivotX(fadedVerticalQuad);

			var verticalQuad : Quad = new Quad(2 * scaleFactor, boardSize.y * viewTileSize, color);
			verticalQuad.pivotY = (y / modelTileSize * viewTileSize) + viewTileSize / 2;
			DisplayUtils.centerPivotX(verticalQuad);

			var sprite : Sprite = new Sprite();
			sprite.addChild(fadedHorizontalQuad);
			sprite.addChild(fadedVerticalQuad);
			sprite.addChild(horizontalQuad);
			sprite.addChild(verticalQuad);
			entity.add(DisplayComponent.create().withDisplayObject(sprite));

			var tween : Tween = new Tween(sprite, 0.075);
			tween.animate("alpha", 0.6);
			tween.repeatCount = int.MAX_VALUE;
			tween.reverse = true;
			entity.add(ScriptComponent.create().withScript(new TweenScript(tween)));

			entity.add(CountdownComponent.create().withTime(0.6));
			entity.add(TransformComponent.create().withX(x).withY(y));

			return entity;
		}

		public function createSpawner(x : Number, y : Number) : Entity
		{
			var entity : Entity = new Entity();

			entity.add(SpawnerComponent.create());
			entity.add(TransformComponent.create().withX(x).withY(y));

			return entity;
		}

		public function createBlocker(x : Number, y : Number) : Entity
		{
			var entity : Entity = new Entity();

			entity.add(BlockComponent.create());
			entity.add(TransformComponent.create().withX(x).withY(y));

			return entity;
		}

		public function createInvisibleBlocker(x : Number, y : Number, duration : Number) : Entity
		{
			var entity : Entity = new Entity();

			entity.name = "invisibleBlocker" + Math.random();

			entity.add(BlockComponent.create());
			entity.add(CountdownComponent.create().withTime(duration));
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