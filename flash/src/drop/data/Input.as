package drop.data
{
	import flash.geom.Point;

	public class Input
	{
		public static const TOUCH_BEGAN : int = 1;
		public static const TOUCH_MOVE : int = 2;
		public static const TOUCH_ENDED : int = 3;

		public var type : int;
		public var location : Point;

		public function Input(type : int, location : Point)
		{
			this.type = type;
			this.location = location;
		}
	}
}