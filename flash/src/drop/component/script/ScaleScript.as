package drop.component.script
{
	import drop.component.TransformComponent;

	public class ScaleScript extends Script
	{
		private var transformComponent : TransformComponent;
		private var scale : Number;

		public function ScaleScript(transformComponent : TransformComponent, scale : Number)
		{
			this.transformComponent = transformComponent;
			this.scale = scale;
		}

		override public function start() : void
		{
			transformComponent.scale = scale;
		}

		override public function end() : void
		{
			transformComponent.scale = 1;
		}
	}
}
