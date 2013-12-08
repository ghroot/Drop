package drop.system
{
	import ash.core.Engine;
	import ash.core.System;

	import drop.node.GameNode;

	public class AddPendingCreditsSystem extends System
	{
		private var gameNode : GameNode;

		public function AddPendingCreditsSystem()
		{
		}

		override public function addToEngine(engine : Engine) : void
		{
			gameNode = engine.getNodeList(GameNode).head;
		}

		override public function update(time : Number) : void
		{
			gameNode.gameStateComponent.credits += gameNode.gameStateComponent.pendingCredits;
			gameNode.gameStateComponent.creditsUpdated.dispatch();

			gameNode.gameStateComponent.pendingCredits = 0;
			gameNode.gameStateComponent.pendingCreditsUpdated.dispatch();
		}
	}
}
