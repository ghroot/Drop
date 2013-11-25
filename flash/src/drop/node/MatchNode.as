package drop.node
{
	import ash.core.Node;

	import drop.component.MatchComponent;
	import drop.component.StateComponent;
	import drop.component.TransformComponent;

	public class MatchNode extends Node
	{
		public var matchComponent : MatchComponent;
		public var transformComponent : TransformComponent;
		public var stateComponent : StateComponent;
	}
}
