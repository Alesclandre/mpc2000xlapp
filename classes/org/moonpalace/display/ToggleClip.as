package org.moonpalace.display
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class ToggleClip extends MovieClip
	{
		private const ON:String = "ON";
		private const OFF:String = "OFF";
		
		private var _isOn:Boolean = true;
		
		public function ToggleClip()
		{
			super();
			stop();
			
			addEventListener( Event.ADDED_TO_STAGE, activation );
			addEventListener( Event.REMOVED_FROM_STAGE, desactivation );
		}

		public function setTo( on:Boolean ) {
			if( on ) gotoAndStop( ON );
			else gotoAndStop( OFF );
			_isOn = on;
		}

		private function desactivation(event:Event):void
		{
			
		}

		private function activation(event:Event):void
		{
			
		}		
		
		public function get isOn():Boolean {
			return _isOn;
		}
	}
}