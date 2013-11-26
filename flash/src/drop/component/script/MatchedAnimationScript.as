package drop.component.script
{
	import drop.component.TransformComponent;

	import starling.animation.Tween;

	public class MatchedAnimationScript extends Script
	{
		private var transformComponent : TransformComponent;

		private var tween1 : Tween;
		private var tween2 : Tween;

		public function MatchedAnimationScript(transformComponent : TransformComponent)
		{
			this.transformComponent = transformComponent;
		}

		override public function start() : void
		{
			tween1 = new Tween(transformComponent, 0.2);
			tween1.animate("scale", 0.75);

			tween2 = new Tween(transformComponent, 0.2);
			tween2.delay = 0.2;
			tween2.animate("scale", 0);
		}

		override public function update(time : Number) : void
		{
			if (tween1 != null)
			{
				tween1.advanceTime(time);
			}
			if (tween2 != null)
			{
				tween2.advanceTime(time);
			}
		}

		override public function end() : void
		{
			tween1 = null;
			tween2 = null;
		}
	}
}
