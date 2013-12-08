package drop.system
{
	import ash.core.Engine;
	import ash.core.System;

	import drop.data.Input;
	import drop.node.GameNode;

	import flash.geom.Point;

	import starling.display.DisplayObject;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	public class TouchInputSystem extends System
	{
		private var boardDisplayObject : DisplayObject;

		private var gameNode : GameNode;
		private var inputsSinceLastUpdate : Vector.<Input>;

		public function TouchInputSystem(boardDisplayObject : DisplayObject)
		{
			this.boardDisplayObject = boardDisplayObject;
		}

		override public function addToEngine(engine : Engine) : void
		{
			gameNode = engine.getNodeList(GameNode).head;

			inputsSinceLastUpdate = new Vector.<Input>();

			boardDisplayObject.addEventListener(TouchEvent.TOUCH, onTouch);
		}

		override public function removeFromEngine(engine : Engine) : void
		{
			boardDisplayObject.removeEventListener(TouchEvent.TOUCH, onTouch);
		}

		override public function update(time : Number) : void
		{
			for each (var input : Input in inputsSinceLastUpdate)
			{
				gameNode.gameStateComponent.inputs[gameNode.gameStateComponent.inputs.length] = input;
			}

			inputsSinceLastUpdate.length = 0;
		}

		private function onTouch(event : TouchEvent) : void
		{
			var touch : Touch = event.getTouch(boardDisplayObject);
			if (touch != null)
			{
				var position : Point = touch.getLocation(boardDisplayObject);

				if (touch.phase == TouchPhase.BEGAN)
				{
					inputsSinceLastUpdate.push(new Input(Input.TOUCH_BEGAN, position));
				}
				else if (touch.phase == TouchPhase.MOVED)
				{
					inputsSinceLastUpdate.push(new Input(Input.TOUCH_MOVE, position));
				}
			}
		}
	}
}