package drop.component.script
{
	import drop.component.DisplayComponent;
	import drop.component.TransformComponent;

	import starling.animation.Tween;

	public class AlphaScript extends Script
	{
		private var displayComponent : DisplayComponent;
		private var alpha : Number;
		private var tweenDuration : Number;
		private var resetOnEnd : Boolean;

		private var tween : Tween;

		public function AlphaScript(displayComponent : DisplayComponent, alpha : Number, tweenDuration : Number = 0, resetOnEnd : Boolean = false)
		{
			this.displayComponent = displayComponent;
			this.alpha = alpha;
			this.tweenDuration = tweenDuration;
			this.resetOnEnd = resetOnEnd;
		}

		override public function start() : void
		{
			if (tweenDuration == 0)
			{
				displayComponent.displayComponentContainer.alpha = alpha;
			}
			else
			{
				tween = new Tween(displayComponent.displayComponentContainer, tweenDuration);
				tween.animate("alpha", alpha);
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
				displayComponent.displayComponentContainer.alpha = 1;
			}
			tween = null;
		}
	}
}
