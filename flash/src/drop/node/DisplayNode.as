package drop.node
{
	import ash.core.Node;

	import drop.component.DisplayComponent;
	import drop.component.TransformComponent;

	public class DisplayNode extends Node
	{
		public var transformComponent : TransformComponent;
		public var displayComponent : DisplayComponent;
	}
}