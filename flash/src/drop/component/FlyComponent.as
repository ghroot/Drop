package drop.component
{
	public class FlyComponent
	{
		public var velocityX : Number;
		public var velocityY : Number;

		public function FlyComponent(velocityX : Number = 0, velocityY : Number = 0)
		{
			this.velocityX = velocityX;
			this.velocityY = velocityY;
		}
	}
}
