package drop.component
{
	import ash.tools.ComponentPool;

	import drop.data.Countdown;

	public class CountdownComponent
	{
		public var time : Number;
		public var stateToChangeTo : String;

		public var countdown : Countdown;

		public static function create() : CountdownComponent
		{
			var component : CountdownComponent = ComponentPool.get(CountdownComponent);
			component.reset();
			return component;
		}

		public function reset() : void
		{
			time = 0;
			stateToChangeTo = null;
			countdown = null;
		}

		public function withTime(value : Number) : CountdownComponent
		{
			time = value;
			return this;
		}

		public function withStateToChangeTo(value : String) : CountdownComponent
		{
			stateToChangeTo = value;
			return this;
		}
	}
}
