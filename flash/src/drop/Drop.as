package drop
{
	import drop.board.Board;

	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;

	import starling.core.Starling;
	import starling.events.Event;
	import starling.textures.Texture;
	import starling.utils.AssetManager;
	import starling.utils.HAlign;
	import starling.utils.RectangleUtil;
	import starling.utils.ScaleMode;
	import starling.utils.VAlign;

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
			var stageWidth : int  = 320;
			var stageHeight : int = 480;
			var iOS : Boolean = Capabilities.manufacturer.indexOf("iOS") != -1;

			Starling.multitouchEnabled = true;
			Starling.handleLostContext = !iOS;

			var viewPort : Rectangle = RectangleUtil.fit(
					new Rectangle(0, 0, stageWidth, stageHeight),
					new Rectangle(0, 0, stage.fullScreenWidth, stage.fullScreenHeight),
					ScaleMode.SHOW_ALL, iOS);

			var scaleFactor : int = viewPort.width < 480 ? 1 : 2;
			var assets : AssetManager = new AssetManager(scaleFactor);

			var startupBitmapClass : Class = scaleFactor == 1 ? StartupBitmap : StartupBitmapHd;
			var startupBitmap : Bitmap = new startupBitmapClass();
			StartupBitmap = StartupBitmapHd = null;
			startupBitmap.x = viewPort.x;
			startupBitmap.y = viewPort.y;
			startupBitmap.width  = viewPort.width;
			startupBitmap.height = viewPort.height;
			startupBitmap.smoothing = true;
			addChild(startupBitmap);

			mStarling = new Starling(Board, stage, viewPort);
			mStarling.stage.stageWidth  = stageWidth;
			mStarling.stage.stageHeight = stageHeight;
			mStarling.simulateMultitouch  = false;
			mStarling.enableErrorChecking = false;
			mStarling.showStatsAt(HAlign.LEFT, VAlign.BOTTOM);

			mStarling.addEventListener(starling.events.Event.ROOT_CREATED, function(event : *) : void
			{
				removeChild(startupBitmap);
				startupBitmap = null;

				var board : Board = mStarling.root as Board;
				var startupTexture : Texture = Texture.fromEmbeddedAsset(startupBitmapClass, false, false, scaleFactor);
				board.start(startupTexture, assets);
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
	}
}
