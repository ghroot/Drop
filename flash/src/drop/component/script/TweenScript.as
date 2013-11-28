package drop.component.script
{
	import starling.animation.Tween;

	public class TweenScript extends Script
	{
		private var tween : Tween;

		public function TweenScript(tween : Tween)
		{
			this.tween = tween;
		}

		override public function update(time : Number) : void
		{
			tween.advanceTime(time);
		}

		override public function end() : void
		{
			tween = null;
		}
	}
}
