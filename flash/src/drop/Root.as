package drop
{
	import drop.board.*;
	import drop.stats.StatsScreen;

	import feathers.controls.ScreenNavigator;
	import feathers.controls.ScreenNavigatorItem;
	import feathers.motion.transitions.ScreenSlidingStackTransitionManager;
	import feathers.themes.MinimalMobileTheme;

	import starling.display.Sprite;
	import starling.text.BitmapFont;
	import starling.text.TextField;
	import starling.textures.Texture;

	public class Root extends Sprite
	{
		[Embed(source="../../res/font.png")]
		public const FontBitmap : Class;

		[Embed(source="../../res/font.fnt", mimeType="application/octet-stream")]
		public const FontXml : Class;

		[Embed(source="../../res/fontSmall.png")]
		public const FontSmallBitmap : Class;

		[Embed(source="../../res/fontSmall.fnt", mimeType="application/octet-stream")]
		public const FontSmallXml : Class;

		[Embed(source="../../res/font-hd.png")]
		public const FontHdBitmap : Class;

		[Embed(source="../../res/font-hd.fnt", mimeType="application/octet-stream")]
		public const FontHdXml : Class;

		[Embed(source="../../res/fontSmall-hd.png")]
		public const FontSmallHdBitmap : Class;

		[Embed(source="../../res/fontSmall-hd.fnt", mimeType="application/octet-stream")]
		public const FontSmallHdXml : Class;

		private var navigator : ScreenNavigator;
		private var transitionManager : ScreenSlidingStackTransitionManager;

		public function Root()
		{
			new MinimalMobileTheme();
		}

		public function start(scaleFactor : Number) : void
		{
			if (scaleFactor == 1)
			{
				TextField.registerBitmapFont(new BitmapFont(Texture.fromBitmap(new FontBitmap()), XML(new FontXml())), "Quicksand");
				TextField.registerBitmapFont(new BitmapFont(Texture.fromBitmap(new FontSmallBitmap()), XML(new FontSmallXml())), "QuicksandSmall");
			}
			else
			{
				TextField.registerBitmapFont(new BitmapFont(Texture.fromBitmap(new FontHdBitmap()), XML(new FontHdXml())), "Quicksand");
				TextField.registerBitmapFont(new BitmapFont(Texture.fromBitmap(new FontSmallHdBitmap()), XML(new FontSmallHdXml())), "QuicksandSmall");
			}

			navigator = new ScreenNavigator();
			addChild(navigator);

			transitionManager = new ScreenSlidingStackTransitionManager(navigator);

			var sharedState : Object = {};

			navigator.addScreen("board", new ScreenNavigatorItem(new BoardScreen(scaleFactor, sharedState), { onStats: "stats" }));
			navigator.addScreen("stats", new ScreenNavigatorItem(new StatsScreen(scaleFactor, sharedState), { onBack: "board" }));

			navigator.showScreen("board");
		}
	}
}
