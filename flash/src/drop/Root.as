package drop
{
	import drop.board.*;

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

		public function Root()
		{
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

			addChild(new Board(scaleFactor));
		}
	}
}
