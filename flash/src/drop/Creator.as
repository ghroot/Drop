package drop
{
	import ash.core.Entity;
	import ash.fsm.EntityState;
	import ash.fsm.EntityStateMachine;

	import drop.component.BlockComponent;
	import drop.component.BoundsComponent;
	import drop.component.CountdownComponent;
	import drop.component.DisplayComponent;
	import drop.component.FlyComponent;
	import drop.component.LineBlastComponent;
	import drop.component.LineBlastPulseComponent;
	import drop.component.LineBlastTargetComponent;
	import drop.component.MoveComponent;
	import drop.component.SelectComponent;
	import drop.component.SpawnerComponent;
	import drop.component.StateComponent;
	import drop.component.TransformComponent;

	import flash.geom.Point;

	import starling.display.Quad;

	public class Creator
	{
		private var boardSize : Point;
		private var tileSize : int;

		public function Creator(boardSize : Point, tileSize : int)
		{
			this.boardSize = boardSize;
			this.tileSize = tileSize;
		}

		public function createTile(x : Number, y : Number) : Entity
		{
			var entity : Entity = new Entity();

			var stateMachine : EntityStateMachine = new EntityStateMachine(entity);

			var color : int = Math.random() * 16777215;

			var idleState : EntityState = stateMachine.createState("idle");
			idleState.add(LineBlastTargetComponent).withInstance(new LineBlastTargetComponent());
			var idleQuad : Quad = new Quad(tileSize, tileSize, color);
			idleQuad.touchable = false;
			idleState.add(DisplayComponent).withInstance(new DisplayComponent(idleQuad));

			var selectedState : EntityState = stateMachine.createState("selected");
			var selectedQuad : Quad = new Quad(tileSize - 10, tileSize - 10, color);
			selectedQuad.pivotX = selectedQuad.pivotY = -5;
			selectedQuad.touchable = false;
			selectedState.add(DisplayComponent).withInstance(new DisplayComponent(selectedQuad));

			var matchedState : EntityState = stateMachine.createState("matched");
			matchedState.add(CountdownComponent).withInstance(new CountdownComponent(0));

			var destroyedByLineBlastState : EntityState = stateMachine.createState("destroyedByLineBlast");
			destroyedByLineBlastState.add(CountdownComponent).withInstance(new CountdownComponent(0.6));

			entity.add(new TransformComponent(x, y));
			entity.add(new BlockComponent());
			entity.add(new MoveComponent());
			entity.add(new SelectComponent());
			entity.add(new StateComponent(stateMachine));

			stateMachine.changeState("idle");

			return entity;
		}

		public function createLineBlast(x : Number, y : Number) : Entity
		{
			var entity : Entity = new Entity();

			var stateMachine : EntityStateMachine = new EntityStateMachine(entity);

			var color : int = 0xaaaaaa;

			var idleState : EntityState = stateMachine.createState("idle");
			idleState.add(LineBlastComponent).withInstance(new LineBlastComponent(false));
			idleState.add(LineBlastTargetComponent).withInstance(new LineBlastTargetComponent());
			var idleQuad : Quad = new Quad(tileSize, tileSize, color);
			idleQuad.touchable = false;
			idleState.add(DisplayComponent).withInstance(new DisplayComponent(idleQuad));

			var selectedState : EntityState = stateMachine.createState("selected");
			selectedState.add(LineBlastComponent).withInstance(new LineBlastComponent(false));
			var selectedQuad : Quad = new Quad(tileSize - 10, tileSize - 10, color);
			selectedQuad.pivotX = selectedQuad.pivotY = -5;
			selectedQuad.touchable = false;
			selectedState.add(DisplayComponent).withInstance(new DisplayComponent(selectedQuad));

			var matchedState : EntityState = stateMachine.createState("matched");
			matchedState.add(CountdownComponent).withInstance(new CountdownComponent(0, "triggered"));

			var triggeredState : EntityState = stateMachine.createState("triggered");
			triggeredState.add(LineBlastComponent).withInstance(new LineBlastComponent(true));

			var detonatedState : EntityState = stateMachine.createState("detonated");
			detonatedState.add(CountdownComponent).withInstance(new CountdownComponent(0.6));

			var destroyedByLineBlastState : EntityState = stateMachine.createState("destroyedByLineBlast");
			destroyedByLineBlastState.add(CountdownComponent).withInstance(new CountdownComponent(0, "triggered"));

			entity.add(new TransformComponent(x, y));
			entity.add(new BlockComponent());
			entity.add(new MoveComponent());
			entity.add(new SelectComponent());
			entity.add(new StateComponent(stateMachine));

			stateMachine.changeState("idle");

			return entity;
		}

		public function createLineBlastPulse(x : Number, y : Number, blastDirectionX : int, blastDirectionY : int) : Entity
		{
			var entity : Entity = new Entity();

			var quad : Quad = new Quad(tileSize / 2, tileSize / 2, 0xcccccc);
			quad.pivotX = quad.pivotY = -tileSize / 4;
			quad.touchable = false;
			entity.add(new DisplayComponent(quad));

			entity.add(new FlyComponent(extend(blastDirectionX, 16), extend(blastDirectionY, 16)));
			entity.add(new BoundsComponent(0, 0, boardSize.x * tileSize, boardSize.y * tileSize));
			entity.add(new TransformComponent(x + cap(blastDirectionX, 30), y + cap(blastDirectionY, 30)));
			entity.add(new LineBlastPulseComponent());

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
			entity.add(new TransformComponent(x, y));

			return entity;
		}

		public function createBlocker(x : Number, y : Number) : Entity
		{
			var entity : Entity = new Entity();

			entity.add(new BlockComponent());
			entity.add(new TransformComponent(x, y));

			return entity;
		}
	}
}