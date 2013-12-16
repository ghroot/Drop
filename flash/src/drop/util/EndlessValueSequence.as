package drop.util
{
	public class EndlessValueSequence
	{
		private var startValue : int;
		private var nextValueFunction : Function;

		public function EndlessValueSequence(startValue : int, nextValueFunction : Function)
		{
			this.startValue = startValue;
			this.nextValueFunction = nextValueFunction;
		}

		public function getValue(n : int) : int
		{
			var previousValue : int = 0;
			var value : int = startValue;
			for (var i : int = 0; i < n; i++)
			{
				var nextValue : int = nextValueFunction(previousValue, value);
				previousValue = value;
				value = nextValue;
			}
			return value;
		}
	}
}
