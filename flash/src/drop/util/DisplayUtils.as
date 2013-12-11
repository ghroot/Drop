package drop.util
{
	import starling.display.DisplayObject;

	public class DisplayUtils
	{
		public static function centerPivot(displayObject : DisplayObject, offsetX : Number = 0, offsetY : Number = 0) : void
		{
			centerPivotX(displayObject, offsetX);
			centerPivotY(displayObject, offsetY);
		}

		public static function centerPivotX(displayObject : DisplayObject, offsetX : Number = 0) : void
		{
			displayObject.pivotX = Math.round(displayObject.width / 2) + offsetX;
		}

		public static function centerPivotY(displayObject : DisplayObject, offsetY : Number = 0) : void
		{
			displayObject.pivotY = Math.round(displayObject.height / 2) + offsetY;
		}

		public static function blendColor(color : uint, into : uint = 0xffffffff, factor : Number = 0.5, blendAlpha : Boolean = false) : uint
		{
			if (factor < 0 || factor > 1)
			{
				factor = 0.5;
			}
			var a1 : uint = (color >> 24) & 0xFF;
			var r1 : uint = (color >> 16) & 0xFF;
			var g1 : uint = (color >> 8) & 0xFF;
			var b1 : uint = (color >> 0) & 0xFF;
			var a2 : uint = (into >> 24) & 0xFF;
			var r2 : uint = (into >> 16) & 0xFF;
			var g2 : uint = (into >> 8) & 0xFF;
			var b2 : uint = (into >> 0) & 0xFF;
			var a3 : uint = (a1 * factor + a2 * (1 - factor)) & 0xFF;
			var r3 : uint = (r1 * factor + r2 * (1 - factor)) & 0xFF;
			var g3 : uint = (g1 * factor + g2 * (1 - factor)) & 0xFF;
			var b3 : uint = (b1 * factor + b2 * (1 - factor)) & 0xFF;
			return ( blendAlpha ? a3 << 24 : 0x0 ) | (r3 << 16) | (g3 << 8) | b3;
		}
	}
}
