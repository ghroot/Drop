package drop.node
{
	import ash.core.Node;

	import drop.component.LineBlastComponent;
	import drop.component.StateComponent;
	import drop.component.TransformComponent;

	public class LineBlastNode extends Node
	{
		public var lineBlastComponent : LineBlastComponent;
		public var transformComponent : TransformComponent;
		public var stateComponent : StateComponent;
	}
}
