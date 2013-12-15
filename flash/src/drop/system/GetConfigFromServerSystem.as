package drop.system
{
	import ash.core.Engine;
	import ash.core.System;

	import drop.node.GameNode;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class GetConfigFromServerSystem extends System
	{
		private static const URL : String = "http://scores-dropscores.rhcloud.com/config";

		private var gameNode : GameNode;

		public function GetConfigFromServerSystem()
		{
		}

		override public function addToEngine(engine : Engine) : void
		{
			gameNode = engine.getNodeList(GameNode).head;
		}

		override public function update(time : Number) : void
		{
				var urlLoader : URLLoader = new URLLoader();
				urlLoader.addEventListener(Event.COMPLETE, onUrlLoaderComplete);
				urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
				urlLoader.load(new URLRequest(URL));
		}

		private function onUrlLoaderComplete(event : Event) : void
		{
			event.target.addEventListener(Event.COMPLETE, onUrlLoaderComplete);
			event.target.addEventListener(IOErrorEvent.IO_ERROR, onIoError);

			var urlLoader : URLLoader = event.target as URLLoader;
			var response : Object = JSON.parse(urlLoader.data);
			gameNode.gameStateComponent.isPercentileEnabled = response.enableHighScores;
		}

		private function onIoError(event : IOErrorEvent) : void
		{
			event.target.addEventListener(Event.COMPLETE, onUrlLoaderComplete);
			event.target.addEventListener(IOErrorEvent.IO_ERROR, onIoError);

			trace("Error getting config from server");
		}
	}
}
