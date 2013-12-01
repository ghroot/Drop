package drop.component
{
	import starling.display.DisplayObject;
	import starling.display.Sprite;

	public class DisplayComponentContainer extends Sprite
	{
		public var displayObject : DisplayObject;
		public var z : int;

		public function DisplayComponentContainer(displayObject : DisplayObject, z : int)
		{
			this.displayObject = displayObject;
			this.z = z;
		}
	}
}
