package drop
{
	import flash.display.Sprite;
	import flash.events.Event;

	import starling.core.Starling;

	[SWF(frameRate="100", width="640", height="960")]
	public class Drop extends Sprite
	{
		public function Drop()
		{
			if (stage != null)
			{
				start();
			}
			else
			{
				addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			}
		}

		private function onAddedToStage(event : Event) : void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

			start();
		}

		private function start() : void
		{
			Starling.handleLostContext = true;

			var starling : Starling = new Starling(Board, stage);
//			starling.showStats = true;
			starling.start();
		}
	}
}
