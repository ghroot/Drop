package drop
{
	import drop.board.Board;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;

	import starling.core.Starling;
	import starling.utils.HAlign;
	import starling.utils.VAlign;

	[SWF(backgroundColor="0xffffff", frameRate="60")]
	public class Drop extends Sprite
	{
		private var starling : Starling;

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

			stage.addEventListener(Event.RESIZE, onResize);

			starling = new Starling(Board, stage);
			starling.showStatsAt(HAlign.LEFT, VAlign.BOTTOM);
			starling.start();
		}

		private function onResize(event : Event) : void
		{
			starling.stage.stageWidth = stage.stageWidth;
			starling.stage.stageHeight = stage.stageHeight;
			const viewPort : Rectangle = starling.viewPort;
			viewPort.width = stage.stageWidth;
			viewPort.height = stage.stageHeight;
			starling.viewPort = viewPort;
		}
	}
}
