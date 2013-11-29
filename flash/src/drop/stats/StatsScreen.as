package drop.stats
{
	import drop.data.MatchPatterns;

	import feathers.controls.Button;
	import feathers.controls.PanelScreen;
	import feathers.layout.VerticalLayout;

	import org.osflash.signals.Signal;

	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.text.TextField;

	public class StatsScreen extends PanelScreen
	{
		private var scaleFactor : Number;
		private var sharedState : Object;

		public var onBack : Signal = new Signal(StatsScreen);

		public function StatsScreen(scaleFactor : Number, sharedState : Object)
		{
			this.scaleFactor = scaleFactor;
			this.sharedState = sharedState;

			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}

		private function onAddedToStage(event : Event) : void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

			var backButton : Button = new Button();
			backButton.label = "Back";
			backButton.addEventListener(Event.TRIGGERED, onBackButtonTriggered);
			addChild(backButton);

			headerProperties.leftItems = new <DisplayObject>[backButton];

			layout = new VerticalLayout();

			for (var pattern : * in sharedState["matchPatternLevels"])
			{
				var textField : TextField = new TextField(stage.stageWidth, 70, getMatchPatternName(pattern) + ": " + sharedState["matchPatternLevels"][pattern].getLevel(), "QuicksandSmall", 20 * scaleFactor);
				addChild(textField);
			}
		}

		private function getMatchPatternName(matchPattern : int) : String
		{
			switch (matchPattern)
			{
				case MatchPatterns.THREE_IN_A_ROW:
					return "Three in a row";
				case MatchPatterns.FOUR_IN_A_ROW:
					return "Four in a row";
				case MatchPatterns.T_OR_L:
					return "T or L";
				case MatchPatterns.FIVE_OR_MORE_IN_A_ROW:
					return "Five in a row";
				default:
					return "";
			}
		}

		private function onBackButtonTriggered(event : Event) : void
		{
			onBack.dispatch(this);
		}
	}
}
