package drop.system
{
	import ash.core.Engine;
	import ash.core.System;

	import drop.node.GameNode;

	public class ComboSystem extends System
	{
		private var gameNode : GameNode;

		public function ComboSystem()
		{
		}

		override public function addToEngine(engine : Engine) : void
		{
			gameNode = engine.getNodeList(GameNode).head;
		}

		override public function update(time : Number) : void
		{
			applyMatchesComboBonus();
			applyLineBlastComboBonus();
		}

		private function applyMatchesComboBonus() : void
		{
			var matchesComboBonus : int = getMatchesComboBonus();
			if (matchesComboBonus > 0)
			{
				gameNode.gameStateComponent.pendingCredits += matchesComboBonus;
				gameNode.gameStateComponent.pendingCreditsUpdated.dispatch();
			}

			gameNode.gameStateComponent.totalNumberOfMatchesDuringCascading = 0;
		}

		private function getMatchesComboBonus() : int
		{
			if (gameNode.gameStateComponent.totalNumberOfMatchesDuringCascading >= 50)
			{
				return 5000;
			}
			else if (gameNode.gameStateComponent.totalNumberOfMatchesDuringCascading >= 20)
			{
				return 1000;
			}
			else if (gameNode.gameStateComponent.totalNumberOfLineBlastsDuringCascading >= 10)
			{
				return 200;
			}
			else
			{
				return 0;
			}
		}

		private function applyLineBlastComboBonus() : void
		{
			var lineBlastComboBonus : int = getLineBlastComboBonus();
			if (lineBlastComboBonus > 0)
			{
				gameNode.gameStateComponent.pendingCredits += lineBlastComboBonus;
				gameNode.gameStateComponent.pendingCreditsUpdated.dispatch();
			}

			gameNode.gameStateComponent.totalNumberOfLineBlastsDuringCascading = 0;
		}

		private function getLineBlastComboBonus() : int
		{
			if (gameNode.gameStateComponent.totalNumberOfLineBlastsDuringCascading >= 10)
			{
				return 1000;
			}
			else if (gameNode.gameStateComponent.totalNumberOfLineBlastsDuringCascading >= 5)
			{
				return 300;
			}
			else if (gameNode.gameStateComponent.totalNumberOfLineBlastsDuringCascading >= 3)
			{
				return 50;
			}
			else
			{
				return 0;
			}
		}
	}
}
