package drop.util
{
	import flash.net.NetworkInfo;
	import flash.net.NetworkInterface;

	public class NetworkUtils
	{
		public static function getUniqueId() : String
		{
			if (NetworkInfo.isSupported)
			{
				for each (var networkInterface : NetworkInterface in NetworkInfo.networkInfo.findInterfaces())
				{
					if (networkInterface.hardwareAddress != null &&
							networkInterface.hardwareAddress.length > 0)
					{
						var hardwareAddress : String = networkInterface.hardwareAddress;
						while (hardwareAddress.indexOf(":") >= 0)
						{
							hardwareAddress = hardwareAddress.replace(":", "");
						}
						while (hardwareAddress.indexOf(" ") >= 0)
						{
							hardwareAddress = hardwareAddress.replace(" ", "");
						}
						return hardwareAddress;
					}
				}
			}
			return null;
		}
	}
}
