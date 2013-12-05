package drop.component.script
{
	import drop.component.DisplayComponent;
	import drop.component.DisplayComponentContainer;

	import starling.animation.Tween;
	import starling.core.Starling;

	public class AlphaScript extends Script
	{
		private var displayComponent : DisplayComponent;
		private var alpha : Number;
		private var tweenDuration : Number;
		private var resetOnEnd : Boolean;

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
				for each (var displayComponentContainer : DisplayComponentContainer in displayComponent.displayComponentContainers)
				{
					displayComponentContainer.alpha = alpha;
				}
			}
			else
			{
				for each (displayComponentContainer in displayComponent.displayComponentContainers)
				{
					var tween : Tween = new Tween(displayComponentContainer, tweenDuration);
					tween.animate("alpha", alpha);
					Starling.juggler.add(tween);
				}
			}
		}

		override public function end() : void
		{
			for each (var displayComponentContainer : DisplayComponentContainer in displayComponent.displayComponentContainers)
			{
				if (resetOnEnd)
				{
					displayComponentContainer.alpha = 1;
				}
				Starling.juggler.removeTweens(displayComponentContainer);
			}
		}
	}
}
