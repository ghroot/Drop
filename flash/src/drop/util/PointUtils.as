package drop.util
{
	public class PointUtils
	{
		public static function getLength(x : Number, y : Number) : Number
		{
			return Math.sqrt(x * x + y * y);
		}

		public static function normalize(x : Number, y : Number, length : Number) : void
		{
			if (length == 0)
			{
				x = 0;
				y = 0;
			}
			else
			{
				var currentLength : Number = getLength(x, y);
				x /= currentLength;
				y /= currentLength;
				x *= length;
				y *= length;
			}
		}
	}
}
