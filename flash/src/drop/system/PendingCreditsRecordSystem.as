package drop.system
{
	import ash.core.Engine;
	import ash.core.System;

	import drop.node.GameNode;

	public class PendingCreditsRecordSystem extends System
	{
		private var gameNode : GameNode;

		public function PendingCreditsRecordSystem()
		{
		}

		override public function addToEngine(engine : Engine) : void
		{
			gameNode = engine.getNodeList(GameNode).head;
		}

		override public function update(time : Number) : void
		{
			if (gameNode.gameStateComponent.pendingCredits > gameNode.gameStateComponent.pendingCreditsRecord)
			{
				gameNode.gameStateComponent.pendingCreditsRecord = gameNode.gameStateComponent.pendingCredits;
			}
		}
	}
}
