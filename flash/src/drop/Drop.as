package drop
{
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
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
	import starling.utils.formatString;

	[SWF(frameRate="60", backgroundColor="0xffffff")]
	public class Drop extends Sprite
	{
		[Embed(source="../../res/startup.png")]
		private static var Background : Class;

		[Embed(source="../../res/startupHD.png")]
		private static var BackgroundHD : Class;

		private var mStarling : Starling;

		public function Drop()
		{
			var stageWidth : int  = 320;
			var stageHeight : int = stage.fullScreenHeight == 1136 ? 568 : 480;
			var iOS : Boolean = Capabilities.manufacturer.indexOf("iOS") != -1;

			Starling.multitouchEnabled = true;
			Starling.handleLostContext = !iOS;

			var viewPort : Rectangle = RectangleUtil.fit(
					new Rectangle(0, 0, stageWidth, stageHeight),
					new Rectangle(0, 0, stage.fullScreenWidth, stage.fullScreenHeight),
					ScaleMode.SHOW_ALL, iOS);

			var scaleFactor : int = stage.fullScreenWidth < 480 ? 1 : 2;
			var assets : AssetManager = new AssetManager(scaleFactor);
			assets.enqueue(File.applicationDirectory.resolvePath(formatString("{0}x", scaleFactor)));

			var backgroundClass : Class = scaleFactor == 1 ? Background : BackgroundHD;
			var background : Bitmap = new backgroundClass();
			Background = BackgroundHD = null;

			background.x = viewPort.x;
			background.y = viewPort.y;
			background.width  = viewPort.width;
			background.height = viewPort.height;
			background.smoothing = true;
			addChild(background);

			mStarling = new Starling(Root, stage, viewPort);
			mStarling.stage.stageWidth  = stageWidth;
			mStarling.stage.stageHeight = stageHeight;
			mStarling.simulateMultitouch  = false;
			mStarling.enableErrorChecking = false;
//			mStarling.showStatsAt(HAlign.LEFT, VAlign.BOTTOM);

			mStarling.addEventListener(starling.events.Event.ROOT_CREATED, function(event : *) : void
			{
				removeChild(background);
				background = null;

				var board : Root = mStarling.root as Root;
				var bgTexture : Texture = Texture.fromEmbeddedAsset(backgroundClass, false, false, scaleFactor);
				board.start(bgTexture, assets);
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
