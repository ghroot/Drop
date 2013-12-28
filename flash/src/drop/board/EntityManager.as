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
	import drop.component.GameStateComponent;
	import drop.component.LineBlastComponent;
	import drop.component.LineBlastTargetComponent;
	import drop.component.MatchComponent;
	import drop.component.MoveComponent;
	import drop.component.SelectComponent;
	import drop.component.SpawnerComponent;
	import drop.component.StateComponent;
	import drop.component.TransformComponent;
	import drop.component.TypeComponent;
	import drop.component.script.AlphaScript;
	import drop.component.script.ScaleScript;
	import drop.component.script.ScriptComponent;
	import drop.component.script.TweenScript;
	import drop.data.ZOrder;
	import drop.util.DisplayUtils;

	import flash.geom.Point;
	import flash.utils.Dictionary;

	import starling.animation.Tween;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.utils.AssetManager;

	public class EntityManager
	{
		private static const TYPE_TO_COLOR_MAPPING : Dictionary = new Dictionary();
		{
			TYPE_TO_COLOR_MAPPING[1] = 0x009ece;
			TYPE_TO_COLOR_MAPPING[2] = 0xff9e00;
			TYPE_TO_COLOR_MAPPING[3] = 0xf7d708;
			TYPE_TO_COLOR_MAPPING[4] = 0xce0000;
			TYPE_TO_COLOR_MAPPING[5] = 0x9ccf31;
		}

		private var engine : Engine;
		private var assets : AssetManager;
		private var boardSize : Point;
		private var tileSize : int;

		public function EntityManager(engine : Engine, assets : AssetManager, boardSize : Point, tileSize : int)
		{
			this.engine = engine;
			this.assets = assets;
			this.boardSize = boardSize;
			this.tileSize = tileSize;
		}

		public function createGame(uniqueId : uint = 0, credits : int = 0, pendingCreditsRecord : int = 0, matchPatternPoints : Object = null) : Entity
		{
			var entity : Entity = new Entity();

			entity.add(GameStateComponent.create().withUniqueId(uniqueId).withCredits(credits).withPendingCreditsRecord(pendingCreditsRecord).withMatchPatternPoints(matchPatternPoints));
			entity.add(TypeComponent.create().withType("game"));

			return entity;
		}

		public function createTile(x : Number, y : Number, type : int = 0) : Entity
		{
			var entity : Entity = new Entity();

			var stateMachine : EntityStateMachine = new EntityStateMachine(entity);

			if (type == 0)
			{
				type = 1 + Math.floor(Math.random() * 5);
			}
			var image : Image = new Image(assets.getTexture("tile_" + type));
			DisplayUtils.centerPivot(image);
			image.touchable = false;

			var transformComponent : TransformComponent = TransformComponent.create().withX(x).withY(y);
			var selectComponent : SelectComponent = SelectComponent.create();
			var displayComponent : DisplayComponent = DisplayComponent.create().withDisplayObject(image);
			var highlightDisplayComponent : DisplayComponent = DisplayComponent.create().withDisplayObject(image, ZOrder.TOP);

			var idleState : EntityState = stateMachine.createState("idle");
			idleState.add(LineBlastTargetComponent).withInstance(LineBlastTargetComponent.create());
			idleState.add(MoveComponent).withInstance(MoveComponent.create());
			idleState.add(SelectComponent).withInstance(selectComponent);
			idleState.add(DisplayComponent).withInstance(displayComponent);

			var selectedState : EntityState = stateMachine.createState("selected");
			selectedState.add(ScriptComponent).withInstance(ScriptComponent.create().withScript(new ScaleScript(transformComponent, 0.75, 0.05, true)));
			selectedState.add(SelectComponent).withInstance(selectComponent);
			selectedState.add(DisplayComponent).withInstance(displayComponent);

			var highlightedState : EntityState = stateMachine.createState("highlighted");
			highlightedState.add(ScriptComponent).withInstance(ScriptComponent.create().withScript(new ScaleScript(transformComponent, 1.5, 1)));
			highlightedState.add(DisplayComponent).withInstance(highlightDisplayComponent);
			highlightedState.add(CountdownComponent).withInstance(CountdownComponent.create().withTime(4).withStateToChangeTo("highlightedDone"));

			var highlightedDoneState : EntityState = stateMachine.createState("highlightedDone");
			highlightedDoneState.add(ScriptComponent).withInstance(ScriptComponent.create().withScript(new ScaleScript(transformComponent, 1, 0.5)));
			highlightedDoneState.add(DisplayComponent).withInstance(highlightDisplayComponent);
			highlightedDoneState.add(CountdownComponent).withInstance(CountdownComponent.create().withTime(1).withStateToChangeTo("matched"));

			var fadedState : EntityState = stateMachine.createState("faded");
			fadedState.add(ScriptComponent).withInstance(ScriptComponent.create().withScript(new AlphaScript(displayComponent, 0.1, 1)));
			fadedState.add(DisplayComponent).withInstance(displayComponent);
			fadedState.add(CountdownComponent).withInstance(CountdownComponent.create().withTime(4).withStateToChangeTo("fadedDone"));

			var fadedDoneState : EntityState = stateMachine.createState("fadedDone");
			fadedDoneState.add(ScriptComponent).withInstance(ScriptComponent.create().withScript(new AlphaScript(displayComponent, 1, 0.5)));
			fadedDoneState.add(DisplayComponent).withInstance(displayComponent);
			fadedDoneState.add(CountdownComponent).withInstance(CountdownComponent.create().withTime(1).withStateToChangeTo("idle"));

			var matchedState : EntityState = stateMachine.createState("matched");
			matchedState.add(DisplayComponent).withInstance(displayComponent);
			matchedState.add(ScriptComponent).withInstance(ScriptComponent.create().withScript(new ScaleScript(transformComponent, 0, 0.4)));
			matchedState.add(CountdownComponent).withInstance(CountdownComponent.create().withTime(0.4));

			var destroyedByLineBlastState : EntityState = stateMachine.createState("destroyedByLineBlast");
			destroyedByLineBlastState.add(ScriptComponent).withInstance(ScriptComponent.create().withScript(new ScaleScript(transformComponent, 0, 0.2)));
			destroyedByLineBlastState.add(DisplayComponent).withInstance(displayComponent);
			destroyedByLineBlastState.add(CountdownComponent).withInstance(CountdownComponent.create().withTime(0.6));

			entity.add(transformComponent);
			entity.add(BlockComponent.create());
			entity.add(MatchComponent.create().withType(type));
			entity.add(StateComponent.create().withStateMachine(stateMachine));
			entity.add(TypeComponent.create().withType("tile"));

			stateMachine.changeState("idle");

			return entity;
		}

		public function createLineBlast(x : Number, y : Number, type : int = 0) : Entity
		{
			var entity : Entity = new Entity();

			var stateMachine : EntityStateMachine = new EntityStateMachine(entity);

			if (type == 0)
			{
				type = 1 + Math.floor(Math.random() * 5);
			}
			var image : Image = new Image(assets.getTexture("lineblast_" + type));
			DisplayUtils.centerPivot(image);
			image.touchable = false;

			var transformComponent : TransformComponent = TransformComponent.create().withX(x).withY(y);
			var selectComponent : SelectComponent = SelectComponent.create();
			var displayComponent : DisplayComponent = DisplayComponent.create().withDisplayObject(image);
			var highlightDisplayComponent : DisplayComponent = DisplayComponent.create().withDisplayObject(image, ZOrder.TOP);
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

			var highlightedState : EntityState = stateMachine.createState("highlighted");
			highlightedState.add(ScriptComponent).withInstance(ScriptComponent.create().withScript(new ScaleScript(transformComponent, 1.5, 1)));
			highlightedState.add(DisplayComponent).withInstance(highlightDisplayComponent);
			highlightedState.add(CountdownComponent).withInstance(CountdownComponent.create().withTime(4).withStateToChangeTo("highlightedDone"));

			var highlightedDoneState : EntityState = stateMachine.createState("highlightedDone");
			highlightedDoneState.add(ScriptComponent).withInstance(ScriptComponent.create().withScript(new ScaleScript(transformComponent, 1, 0.5)));
			highlightedDoneState.add(DisplayComponent).withInstance(highlightDisplayComponent);
			highlightedDoneState.add(CountdownComponent).withInstance(CountdownComponent.create().withTime(1).withStateToChangeTo("matched"));

			var fadedState : EntityState = stateMachine.createState("faded");
			fadedState.add(ScriptComponent).withInstance(ScriptComponent.create().withScript(new AlphaScript(displayComponent, 0.1, 1)));
			fadedState.add(DisplayComponent).withInstance(displayComponent);
			fadedState.add(CountdownComponent).withInstance(CountdownComponent.create().withTime(4).withStateToChangeTo("fadedDone"));

			var fadedDoneState : EntityState = stateMachine.createState("fadedDone");
			fadedDoneState.add(ScriptComponent).withInstance(ScriptComponent.create().withScript(new AlphaScript(displayComponent, 1, 0.5)));
			fadedDoneState.add(DisplayComponent).withInstance(displayComponent);
			fadedDoneState.add(CountdownComponent).withInstance(CountdownComponent.create().withTime(1).withStateToChangeTo("idle"));

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
			entity.add(MatchComponent.create().withType(type));
			entity.add(StateComponent.create().withStateMachine(stateMachine));
			entity.add(TypeComponent.create().withType("lineBlast"));

			stateMachine.changeState("idle");

			return entity;
		}

		public function createLineBlastPulse(x : Number, y : Number, type : int) : Entity
		{
			var entity : Entity = new Entity();

			var color : int = TYPE_TO_COLOR_MAPPING[type];

			var fadedHorizontalQuad : Quad = new Quad(boardSize.x * tileSize, 14, color);
			fadedHorizontalQuad.alpha = 0.2;
			fadedHorizontalQuad.pivotX = (x / tileSize * tileSize) + tileSize / 2;
			DisplayUtils.centerPivotY(fadedHorizontalQuad);

			var horizontalQuad : Quad = new Quad(boardSize.x * tileSize, 4, color);
			horizontalQuad.pivotX = (x / tileSize * tileSize) + tileSize / 2;
			DisplayUtils.centerPivotY(horizontalQuad);

			var fadedVerticalQuad : Quad = new Quad(14, boardSize.y * tileSize, color);
			fadedVerticalQuad.alpha = 0.2;
			fadedVerticalQuad.pivotY = y + tileSize / 2;
			DisplayUtils.centerPivotX(fadedVerticalQuad);

			var verticalQuad : Quad = new Quad(4, boardSize.y * tileSize, color);
			verticalQuad.pivotY = y + tileSize / 2;
			DisplayUtils.centerPivotX(verticalQuad);

			var sprite : Sprite = new Sprite();
			sprite.addChild(fadedHorizontalQuad);
			sprite.addChild(fadedVerticalQuad);
			sprite.addChild(horizontalQuad);
			sprite.addChild(verticalQuad);
			entity.add(DisplayComponent.create().withDisplayObject(sprite, ZOrder.TOP));

			var pulsateTween : Tween = new Tween(sprite, 0.075);
			pulsateTween.animate("alpha", 0.6);
			pulsateTween.repeatCount = 2;
			pulsateTween.reverse = true;
			var fadeTween : Tween = new Tween(sprite, 0.45);
			fadeTween.delay = 0.15;
			fadeTween.animate("alpha", 0);
			entity.add(ScriptComponent.create().withScript(new TweenScript(pulsateTween)).withScript(new TweenScript(fadeTween)));

			entity.add(CountdownComponent.create().withTime(0.6));
			entity.add(TransformComponent.create().withX(x).withY(y));

			return entity;
		}

		public function createSpawner(x : Number, y : Number, spawnerLevel : int = 0) : Entity
		{
			var entity : Entity = new Entity();

			entity.add(SpawnerComponent.create().withSpawnerLevel(spawnerLevel));
			entity.add(TransformComponent.create().withX(x).withY(y));
			entity.add(TypeComponent.create().withType("spawner"));

			return entity;
		}

		public function createBlocker(x : Number, y : Number) : Entity
		{
			var entity : Entity = new Entity();

			entity.add(BlockComponent.create());
			entity.add(TransformComponent.create().withX(x).withY(y));
			entity.add(TypeComponent.create().withType("blocker"));

			return entity;
		}

		public function createInvisibleBlocker(x : Number, y : Number, duration : Number) : Entity
		{
			var entity : Entity = new Entity();

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