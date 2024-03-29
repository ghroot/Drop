package drop.component.script
{
	import drop.component.TransformComponent;

	import starling.animation.Tween;

	public class ScaleScript extends Script
	{
		private var transformComponent : TransformComponent;
		private var scale : Number;
		private var tweenDuration : Number;
		private var resetOnEnd : Boolean;

		private var tween : Tween;

		public function ScaleScript(transformComponent : TransformComponent, scale : Number, tweenDuration : Number = 0, resetOnEnd : Boolean = false)
		{
			this.transformComponent = transformComponent;
			this.scale = scale;
			this.tweenDuration = tweenDuration;
			this.resetOnEnd = resetOnEnd;
		}

		override public function start() : void
		{
			if (tweenDuration == 0)
			{
				transformComponent.scale = scale;
			}
			else
			{
				tween = new Tween(transformComponent, tweenDuration);
				tween.animate("scale", scale);
			}
		}

		override public function update(time : Number) : void
		{
			if (tween != null)
			{
				tween.advanceTime(time);
			}
		}

		override public function end() : void
		{
			if (resetOnEnd)
			{
				transformComponent.scale = 1;
			}
			tween = null;
		}
	}
}
