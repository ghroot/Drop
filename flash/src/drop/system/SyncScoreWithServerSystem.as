package drop.system
{
	import ash.core.Engine;
	import ash.core.System;

	import drop.node.GameNode;
	import drop.util.NetworkUtils;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class SyncScoreWithServerSystem extends System
	{
		private static const URL : String = "http://scores-dropscores.rhcloud.com/score/";

		private var gameNode : GameNode;

		public function SyncScoreWithServerSystem()
		{
		}

		override public function addToEngine(engine : Engine) : void
		{
			gameNode = engine.getNodeList(GameNode).head;
		}

		override public function update(time : Number) : void
		{
			if (gameNode.gameStateComponent.isPercentileEnabled)
			{
				var uid : String = NetworkUtils.getUniqueId();
				if (uid != null)
				{
					// TODO: This should probaby be 'net worth' instead of current credits
					var score : int = gameNode.gameStateComponent.credits;

					var urlLoader : URLLoader = new URLLoader();
					urlLoader.addEventListener(Event.COMPLETE, onUrlLoaderComplete);
					urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
					urlLoader.load(new URLRequest(URL + uid + "/" + score));
				}
			}
		}

		private function onUrlLoaderComplete(event : Event) : void
		{
			event.target.addEventListener(Event.COMPLETE, onUrlLoaderComplete);
			event.target.addEventListener(IOErrorEvent.IO_ERROR, onIoError);

			var urlLoader : URLLoader = event.target as URLLoader;
			var response : Object = JSON.parse(urlLoader.data);
			gameNode.gameStateComponent.percentile = response.percentile;
			gameNode.gameStateComponent.percentileUpdated.dispatch();
		}

		private function onIoError(event : IOErrorEvent) : void
		{
			event.target.addEventListener(Event.COMPLETE, onUrlLoaderComplete);
			event.target.addEventListener(IOErrorEvent.IO_ERROR, onIoError);

			trace("Error submitting score and getting percentile");
		}
	}
}
