package drop.node
{
	import ash.core.*;

	import drop.component.MoveComponent;
	import drop.component.StateComponent;
	import drop.component.TransformComponent;

	public class MoveNode extends Node
	{
		public var transformComponent : TransformComponent;
		public var moveComponent : MoveComponent;
		public var stateComponent : StateComponent;
	}
}
