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
	}
}
