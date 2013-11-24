package drop.component
{
	import starling.display.DisplayObject;

	public class DisplayComponent
	{
		public var displayObject : DisplayObject;

		public function DisplayComponent(displayObject : DisplayObject = null)
		{
			this.displayObject = displayObject;
		}
	}
}