package Interface.Graphics.Messages
{
	import Application;
	
	import fl.transitions.easing.Strong;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	import gs.TweenLite;
	
	import org.moonpalace.display.MovieClipButton;
	
	/************************************
	*
	*	ATTENTION : le texte est parfois en dur dans l'IDE Flash, dans le symbole correspondant ("Error Name Box");
	*
	*/
	
	public class ErrorNameBox extends MovieClip
	{
		public var name_txt:TextField;
		public var save_mc:MovieClipButton;
		public var cancel_mc:MovieClipButton;
		public var onSave:Function;
		
		public function ErrorNameBox()
		{
			super();
			
			name_txt.text = "";
			name_txt.x = int( name_txt.x );
			name_txt.y = int( name_txt.y );
			save_mc.buttonMode = cancel_mc.buttonMode = true;
			save_mc.mouseChildren = cancel_mc.mouseChildren = false;
			
			addEventListener(Event.ADDED_TO_STAGE, activation );
		}
		
		public function close() {
			TweenLite.to( this, .3, {scaleX:.7, scaleY:.7, ease: Strong.easeIn, onComplete:onClosed } );
		}
		
		private function onClosed() {
			dispatchEvent( new Event( Event.CLOSE ) );
			parent.removeChild(this);
		}

		private function activation(e:Event):void {
			stage.focus = name_txt;
			
			save_mc.addEventListener( MouseEvent.CLICK, onClick );
			cancel_mc.addEventListener( MouseEvent.CLICK, onCancel );
			stage.addEventListener( KeyboardEvent.KEY_DOWN, keyboardHandler );
		}
		
		private function keyboardHandler(e:KeyboardEvent):void {
			if( e.keyCode == Keyboard.ENTER ) {
				onClick();
				stage.removeEventListener( KeyboardEvent.KEY_DOWN, keyboardHandler );
			}
		}

		private function onCancel(e:MouseEvent):void {
			close();
		}

		private function onClick(e:MouseEvent=null):void {
			if( onSave != null && validateName() ) onSave();
		}
		
		private function validateName():Boolean {
			if( name_txt.text == "" ) return false;
			return true;
		}
	}
}