package drop.util
{
	public class MathUtils
	{
		public static function min(number1 : Number, number2 : Number) : Number
		{
			return number1 < number2 ? number1 : number2;
		}

		public static function max(number1 : Number, number2 : Number) : Number
		{
			return number1 > number2 ? number1 : number2;
		}
	}
}
