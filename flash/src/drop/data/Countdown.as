package drop.data
{
	public class Countdown
	{
		private var totalTime : Number;
		private var timeLeft : Number;

		public function Countdown(time : Number)
		{
			resetWithTime(time);
		}

		public function getTimeLeft() : Number
		{
			return timeLeft;
		}

		public function countdown(time : Number) : void
		{
			timeLeft -= time;
		}

		public function hasReachedZero() : Boolean
		{
			return timeLeft <= 0;
		}

		public function countdownAndReturnIfReachedZero(time : Number) : Boolean
		{
			countdown(time);
			return hasReachedZero();
		}

		public function reset() : void
		{
			timeLeft = totalTime;
		}

		public function resetWithTime(time : Number) : void
		{
			totalTime = time;
			reset();
		}
	}
}
