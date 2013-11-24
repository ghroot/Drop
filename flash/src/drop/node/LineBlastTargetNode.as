package drop.node
{
	import ash.core.Node;

	import drop.component.LineBlastTargetComponent;
	import drop.component.StateComponent;
	import drop.component.TransformComponent;

	public class LineBlastTargetNode extends Node
	{
		public var lineBlastTargetComponent : LineBlastTargetComponent;
		public var transformComponent : TransformComponent;
		public var stateComponent : StateComponent;
	}
}
