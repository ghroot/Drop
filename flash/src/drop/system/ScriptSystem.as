package drop.system
{
	import ash.core.Engine;
	import ash.core.NodeList;
	import ash.core.System;

	import drop.component.script.Script;
	import drop.node.ScriptNode;

	public class ScriptSystem extends System
	{
		private var scriptNodeList : NodeList;

		public function ScriptSystem()
		{
		}

		override public function addToEngine(engine : Engine) : void
		{
			scriptNodeList = engine.getNodeList(ScriptNode);

			for (var scriptNode : ScriptNode = scriptNodeList.head; scriptNode; scriptNode = scriptNode.next)
			{
				startScripts(scriptNode);
			}

			scriptNodeList.nodeAdded.add(onNodeAdded);
			scriptNodeList.nodeRemoved.add(onNodeRemoved);
		}

		override public function removeFromEngine(engine : Engine) : void
		{
			for (var scriptNode : ScriptNode = scriptNodeList.head; scriptNode; scriptNode = scriptNode.next)
			{
				endScripts(scriptNode);
			}

			scriptNodeList.nodeAdded.remove(onNodeAdded);
			scriptNodeList.nodeRemoved.remove(onNodeRemoved);
		}

		private function onNodeAdded(scriptNode : ScriptNode) : void
		{
			startScripts(scriptNode);
		}

		private function onNodeRemoved(scriptNode : ScriptNode) : void
		{
			endScripts(scriptNode);
		}

		override public function update(time : Number) : void
		{
			for (var scriptNode : ScriptNode = scriptNodeList.head; scriptNode; scriptNode = scriptNode.next)
			{
				updateScripts(scriptNode, time);
			}
		}

		private function startScripts(scriptNode : ScriptNode) : void
		{
			for each (var script : Script in scriptNode.scriptComponent.scripts)
			{
				script.start();
			}
		}

		private function updateScripts(scriptNode : ScriptNode, time : Number) : void
		{
			for each (var script : Script in scriptNode.scriptComponent.scripts)
			{
				script.update(time);
			}
		}

		private function endScripts(scriptNode : ScriptNode) : void
		{
			for each (var script : Script in scriptNode.scriptComponent.scripts)
			{
				script.end();
			}
		}
	}
}
