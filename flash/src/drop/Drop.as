package drop
{
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;

	import starling.core.Starling;
	import starling.events.Event;

	[SWF(backgroundColor="0xffffff", frameRate="60")]
	public class Drop extends Sprite
	{
		[Embed(source="../../res/startup.png")]
		private static var StartupBitmap : Class;

		[Embed(source="../../res/startup-hd.png")]
		private static var StartupBitmapHd : Class;

		private var mStarling : Starling;

		public function Drop()
		{
			var iOS : Boolean = Capabilities.manufacturer.indexOf("iOS") != -1;

			Starling.multitouchEnabled = true;
			Starling.handleLostContext = !iOS;

			var scaleFactor : int = stage.fullScreenWidth < 480 ? 1 : 2;

			var startupBitmapClass : Class = scaleFactor == 1 ? StartupBitmap : StartupBitmapHd;
			var startupBitmap : Bitmap = new startupBitmapClass();
			StartupBitmap = StartupBitmapHd = null;
			startupBitmap.x = (stage.fullScreenWidth - startupBitmap.width) / 2;
			startupBitmap.y = (stage.fullScreenHeight - startupBitmap.height) / 2;
			addChild(startupBitmap);

			mStarling = new Starling(Root, stage);
			mStarling.simulateMultitouch  = false;
			mStarling.enableErrorChecking = false;
//			mStarling.showStatsAt(HAlign.LEFT, VAlign.BOTTOM);

			stage.addEventListener(flash.events.Event.RESIZE, onResize);

			mStarling.addEventListener(starling.events.Event.ROOT_CREATED, function(event : *) : void
			{
				removeChild(startupBitmap);
				startupBitmap = null;

				var board : Root = mStarling.root as Root;
				board.start(scaleFactor);
				mStarling.start();
			});

			NativeApplication.nativeApplication.addEventListener(flash.events.Event.ACTIVATE, function(event : *) : void
			{
				mStarling.start();
			});
			NativeApplication.nativeApplication.addEventListener(flash.events.Event.DEACTIVATE, function(event : *) : void
			{
				mStarling.stop(true);
			});
		}

		private function onResize(event : *) : void
		{
			if (mStarling != null)
			{
				mStarling.stage.stageWidth = stage.stageWidth;
				mStarling.stage.stageHeight = stage.stageHeight;
				const viewPort : Rectangle = mStarling.viewPort;
				viewPort.width = stage.stageWidth;
				viewPort.height = stage.stageHeight;
				mStarling.viewPort = viewPort;
			}
		}
	}
}
