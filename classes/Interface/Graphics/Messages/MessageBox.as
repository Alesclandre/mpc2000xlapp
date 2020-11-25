package Interface.Graphics.Messages
{
	import fl.transitions.easing.Strong;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.ui.Keyboard;
	
	import gs.TweenLite;
	
	import org.moonpalace.display.MovieClipButton;

	public class MessageBox extends MovieClip
	{
		public var texte_txt:TextField;
		public var ok_mc:MovieClipButton;
		public var fond_mc:MovieClip;
		
		public function MessageBox( text:String="" )
		{
			init( text );
			
			addEventListener(Event.ADDED_TO_STAGE, activation );
			addEventListener(Event.REMOVED_FROM_STAGE, desactivation );
		}
		
		public function init( text:String ) {
			texte_txt.autoSize = TextFieldAutoSize.LEFT;	
			texte_txt.x = int( texte_txt.x );
			texte_txt.y = int( texte_txt.y );
			update( text );
		}
		
		public function update( text:String ) {
			texte_txt.text = text;
			ok_mc.y = texte_txt.y + texte_txt.height + 20;
			fond_mc.height = ok_mc.y - fond_mc.y + ok_mc.height + 20;
		}
		
		private function activation(e:Event):void {
			trace("messagebox activation");
			ok_mc.addEventListener( MouseEvent.CLICK, onClick );
			stage.addEventListener( KeyboardEvent.KEY_DOWN, keyboardHandler );
		}

		private function desactivation(e:Event):void {
			ok_mc.removeEventListener( MouseEvent.CLICK, onClick );	
			stage.removeEventListener( KeyboardEvent.KEY_DOWN, keyboardHandler );		
		}
		
		private function keyboardHandler(e:KeyboardEvent):void {
			trace("messagebox keyboardHandler");
			if( e.keyCode == Keyboard.ENTER ) {
				onClick();
				ok_mc.gotoAndPlay( "out" );
			}
		}
		
		public function close() {
			TweenLite.to( this, .3, {alpha: .6, scaleX:.8, scaleY:.8, ease: Strong.easeIn, onComplete:parent.removeChild, onCompleteParams:[this]} );
		}
		
		private function onClick(e:MouseEvent=null):void {
			close();
		}
	}
}