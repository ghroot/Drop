package drop.data
{
	public class Directions
	{
		public static const NONE : int = 0;
		public static const LEFT : int = 1;
		public static const UP_LEFT : int = 2;
		public static const UP : int = 3;
		public static const UP_RIGHT : int = 4;
		public static const RIGHT : int = 5;
		public static const DOWN_RIGHT : int = 6;
		public static const DOWN : int = 7;
		public static const DOWN_LEFT : int = 8;

		public static const STRAIGHT_DIRECTIONS : Vector.<int> = new <int>[LEFT, RIGHT, UP, DOWN];

		public static function getNextDirection(direction : int) : int
		{
			if (direction == 8)
			{
				return 1;
			}
			else
			{
				return direction + 1;
			}
		}

		public static function getPreviousDirection(direction : int) : int
		{
			if (direction == 1)
			{
				return 8;
			}
			else
			{
				return direction - 1;
			}
		}
	}
}
