package drop
{
	import ash.core.Entity;
	import ash.fsm.EntityState;
	import ash.fsm.EntityStateMachine;

	import drop.component.BlockComponent;
	import drop.component.DisplayComponent;
	import drop.component.MoveComponent;
	import drop.component.SelectComponent;
	import drop.component.SpawnerComponent;
	import drop.component.StateComponent;
	import drop.component.TransformComponent;

	import starling.display.Quad;

	public class Creator
	{
		private var tileSize : int;

		public function Creator(tileSize : int)
		{
			this.tileSize = tileSize;
		}

		public function createTile(x : Number, y : Number) : Entity
		{
			var entity : Entity = new Entity();

			var stateMachine : EntityStateMachine = new EntityStateMachine(entity);

			var color : int = Math.random() * 16777215;

			var idleState : EntityState = stateMachine.createState("idle");
			var idleQuad : Quad = new Quad(tileSize, tileSize, color);
			idleQuad.touchable = false;
			idleState.add(DisplayComponent).withInstance(new DisplayComponent(idleQuad));

			var selectedState : EntityState = stateMachine.createState("selected");
			var selectedQuad : Quad = new Quad(tileSize - 10, tileSize - 10, color);
			selectedQuad.pivotX = selectedQuad.pivotY = -5;
			selectedQuad.touchable = false;
			selectedState.add(DisplayComponent).withInstance(new DisplayComponent(selectedQuad));

			entity.add(new TransformComponent(x, y));
			entity.add(new BlockComponent());
			entity.add(new MoveComponent());
			entity.add(new SelectComponent());
			entity.add(new StateComponent(stateMachine));

			stateMachine.changeState("idle");

			return entity;
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