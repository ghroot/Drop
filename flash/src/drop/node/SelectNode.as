package drop.node
{
	import ash.core.Node;

	import drop.component.SelectComponent;
	import drop.component.StateComponent;
	import drop.component.TransformComponent;

	public class SelectNode extends Node
	{
		public var selectComponent : SelectComponent;
		public var transformComponent : TransformComponent;
		public var stateComponent : StateComponent;
	}
}
