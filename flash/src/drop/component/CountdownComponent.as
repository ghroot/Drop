package drop.component
{
	import drop.data.Countdown;

	public class CountdownComponent
	{
		public var time : Number;
		public var stateToChangeTo : String;

		public var countdown : Countdown;

		public function CountdownComponent(time : Number = 0, stateToChangeTo : String = null)
		{
			this.time = time;
			this.stateToChangeTo = stateToChangeTo;
		}
	}
}
