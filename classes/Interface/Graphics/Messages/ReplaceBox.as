package Interface.Graphics.Messages
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import gs.TweenLite;
	import gs.easing.Strong;
	
	public class ReplaceBox extends MovieClip
	{
		public var replace_mc:MovieClip;
		public var cancel_mc:MovieClip;	
		public var replace:Function;
		
		public function ReplaceBox()
		{
			super();
			
			addEventListener(Event.ADDED_TO_STAGE, activation );
			addEventListener(Event.REMOVED_FROM_STAGE, desactivation );
		}
		
		private function activation(e:Event):void {
			replace_mc.addEventListener( MouseEvent.CLICK, onReplace );
			cancel_mc.addEventListener( MouseEvent.CLICK, onCancel );
			stage.addEventListener( KeyboardEvent.KEY_DOWN, keyboardHandler );
		}
		
		private function desactivation(event:Event):void
		{
			replace_mc.removeEventListener( MouseEvent.CLICK, onReplace );
			cancel_mc.removeEventListener( MouseEvent.CLICK, onCancel );
			stage.removeEventListener( KeyboardEvent.KEY_DOWN, keyboardHandler );
		}
		
		private function onReplace(event:MouseEvent=null):void
		{
			trace("ONreplace dans ReplaceBox");
			dispatchEvent( new Event( Event.CHANGE ) );
			close();
		}
		
		public function close() {
			TweenLite.to( this, .3, {scaleX:.7, scaleY:.7, ease: Strong.easeIn, onComplete:onClosed } );
		}
		
		private function onClosed() {
			parent.removeChild(this);
		}
		
		private function keyboardHandler(e:KeyboardEvent):void {
			if( e.keyCode == Keyboard.ENTER ) {
				onReplace();
				stage.removeEventListener( KeyboardEvent.KEY_DOWN, keyboardHandler );
			}
		}
		
		private function onCancel(e:MouseEvent):void {
			close();
		}
	}
}