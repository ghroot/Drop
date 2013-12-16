package drop.system
{
	import ash.core.Engine;
	import ash.core.NodeList;
	import ash.core.System;

	import drop.data.Countdown;
	import drop.node.GameNode;
	import drop.node.SpawnerNode;
	import drop.util.EndlessValueSequence;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class ScoreSynchronizationSystem extends System
	{
		private static const URL_CONFIG : String = "http://scores-dropscores.rhcloud.com/config";
		private static const URL_SCORE : String = "http://scores-dropscores.rhcloud.com/score";

		private var spawnerLevelCost : EndlessValueSequence;

		private var gameNode : GameNode;
		private var spawnerNodeList : NodeList;
		private var countdown : Countdown;

		public function ScoreSynchronizationSystem(spawnerLevelCost : EndlessValueSequence)
		{
			this.spawnerLevelCost = spawnerLevelCost;
		}

		override public function addToEngine(engine : Engine) : void
		{
			gameNode = engine.getNodeList(GameNode).head;
			spawnerNodeList = engine.getNodeList(SpawnerNode);

			if (gameNode.gameStateComponent.uniqueId == 0)
			{
				gameNode.gameStateComponent.uniqueId = Math.random() * uint.MAX_VALUE;
			}

			var urlLoader : URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, onConfigUrlLoaderComplete);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onConfigIoError);
			urlLoader.load(new URLRequest(URL_CONFIG));
		}

		override public function update(time : Number) : void
		{
			if (countdown != null &&
					countdown.countdownAndReturnIfReachedZero(time))
			{
				countdown.resetWithTime(10);

				if (gameNode.gameStateComponent.isPercentileEnabled &&
						gameNode.gameStateComponent.uniqueId > 0)
				{
					var urlLoader : URLLoader = new URLLoader();
					urlLoader.addEventListener(Event.COMPLETE, onScoreUrlLoaderComplete);
					urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onScoreIoError);
					urlLoader.load(new URLRequest(URL_SCORE + "/" + gameNode.gameStateComponent.uniqueId + "/" + calculateNetWorth()));
				}
			}
		}

		private function calculateNetWorth() : int
		{
			var netWorth : int = gameNode.gameStateComponent.credits;
			for (var spawnerNode : SpawnerNode = spawnerNodeList.head; spawnerNode; spawnerNode = spawnerNode.next)
			{
				netWorth += getTotalSpentOnUpgrade(spawnerNode.spawnerComponent.spawnerLevel);
			}
			return netWorth;
		}

		private function getTotalSpentOnUpgrade(spawnerLevel : int) : int
		{
			var total : int = 0;
			for (var level : int = spawnerLevel - 1; level >= 0; level--)
			{
				total += spawnerLevelCost.getValue(level);
			}
			return total;
		}

		private function onConfigUrlLoaderComplete(event : Event) : void
		{
			event.target.addEventListener(Event.COMPLETE, onConfigUrlLoaderComplete);
			event.target.addEventListener(IOErrorEvent.IO_ERROR, onConfigIoError);

			var urlLoader : URLLoader = event.target as URLLoader;
			var response : Object = JSON.parse(urlLoader.data);
			gameNode.gameStateComponent.isPercentileEnabled = response.enableHighScores;

			countdown = new Countdown(0);
		}

		private function onConfigIoError(event : IOErrorEvent) : void
		{
			event.target.addEventListener(Event.COMPLETE, onConfigUrlLoaderComplete);
			event.target.addEventListener(IOErrorEvent.IO_ERROR, onConfigIoError);

			trace("Error getting config from server");
		}

		private function onScoreUrlLoaderComplete(event : Event) : void
		{
			event.target.addEventListener(Event.COMPLETE, onScoreUrlLoaderComplete);
			event.target.addEventListener(IOErrorEvent.IO_ERROR, onScoreIoError);

			var urlLoader : URLLoader = event.target as URLLoader;
			var response : Object = JSON.parse(urlLoader.data);
			gameNode.gameStateComponent.percentile = response.percentile;
			gameNode.gameStateComponent.percentileUpdated.dispatch();
		}

		private function onScoreIoError(event : IOErrorEvent) : void
		{
			event.target.addEventListener(Event.COMPLETE, onScoreUrlLoaderComplete);
			event.target.addEventListener(IOErrorEvent.IO_ERROR, onScoreIoError);

			trace("Error submitting score and getting percentile");
		}
	}
}
