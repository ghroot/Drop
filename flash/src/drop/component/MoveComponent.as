package drop.component
{
	public class MoveComponent
	{
		public static const FALL_ACCELERATION : int = 160;
		public static const FALL_VELOCITY : int = 10;
		public static const SLIDE_ACCELERATION : int = 160;
		public static const SLIDE_VELOCITY : int = 0;
		public static const MAX_VELOCITY : int = 1200;

		public var velocityX : Number;
		public var velocityY : Number;
		public var accelerationX : Number;
		public var accelerationY : Number;
		public var momentumX : Number;
		public var momentumY : Number;
		public var previousMovingTowardsX : Number;
		public var previousMovingTowardsY : Number;
		public var movingTowardsX : Number;
		public var movingTowardsY : Number;
		public var slidingTowardsPositionX : Number;

		public function MoveComponent()
		{
			velocityX = 0;
			velocityY = 0;
			accelerationX = 0;
			accelerationY = 0;
			momentumX = 0;
			momentumY = 0;
			previousMovingTowardsX = Number.MIN_VALUE;
			previousMovingTowardsY = Number.MIN_VALUE;
			movingTowardsX = Number.MIN_VALUE;
			movingTowardsY = Number.MIN_VALUE;
			slidingTowardsPositionX = 0;
		}
	}
}
