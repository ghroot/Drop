package drop
{
	import drop.board.*;

	import flash.system.System;

	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	import starling.utils.AssetManager;

	public class Root extends Sprite
	{
		public function Root()
		{
		}

		public function start(background : Texture, assets : AssetManager) : void
		{
			addChild(new Image(background));

			assets.loadQueue(function(ratio : Number) : void
			{
				if (ratio == 1)
				{
					System.pauseForGCIfCollectionImminent(0);
					System.gc();

					addChild(new Board(assets));
				}
			});
		}
	}
}
