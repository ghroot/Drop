package drop.component.script
{
	import starling.animation.Tween;
	import starling.core.Starling;

	public class TweenScript extends Script
	{
		private var tween : Tween;

		public function TweenScript(tween : Tween)
		{
			this.tween = tween;
		}

		override public function start() : void
		{
			Starling.juggler.add(tween);
		}

		override public function end() : void
		{
			Starling.juggler.remove(tween);
		}
	}
}
