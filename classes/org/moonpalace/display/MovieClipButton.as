package org.moonpalace.display
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	public class MovieClipButton extends MovieClip
	{
		private const UP:String = "up";
		private const OVER:String = "over";
		private const OUT:String = "out";
		
		//public var enabled:Boolean = true;
		
		public function MovieClipButton()
		{
			super();
			buttonMode = true;
			mouseChildren = false;
			enableButton();
		}
		
		public function enableButton():void {
			enabled = true;
			buttonMode = true;
			addEventListener( MouseEvent.MOUSE_OVER, onOver );
			addEventListener( MouseEvent.MOUSE_OUT, onOut );
		}

		public function disableButton():void {
			enabled= false;
			buttonMode = false;
			removeEventListener( MouseEvent.MOUSE_OVER, onOver );
			removeEventListener( MouseEvent.MOUSE_OUT, onOut );
			gotoAndStop(1);
		}

		private function onOver(e:MouseEvent=null):void {
			if( enabled ) gotoAndPlay( OVER );
		}

		private function onOut(e:MouseEvent=null):void {
			if (enabled ) gotoAndPlay( OUT );
		}
	}
}