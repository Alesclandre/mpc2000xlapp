package Interface.Graphics.SampleList
{
	import MPC2000XL_PGM.GLOBAL;
	import MPC2000XL_PGM.PadBanks;
	import MPC2000XL_PGM.SampleDatas;
	
	import UI.MouseCursors;
	
	import events.SoundsListingEvent;
	
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import org.moonpalace.display.MovieClipButton;
	
	public class SampleClip extends MovieClip
	{
		public var son_txt:TextField;
		public var pad_txt:TextField;
		public var note_txt:TextField;
		public var play_btn:MovieClipButton;
		public var delete_btn:SimpleButton;
		public var deleteFunction:Function;
		public var playSound:Function;
		public var background:BackgroundSampleClip = new BackgroundSampleClip();
		
		public var pads:Array = new Array();
		public var notes:Array = new Array();
		public var sortingPads:String;
		public var sortingNotes:String;
		public var sortingName:String;
		
		private var _sample:SampleDatas;
		
		public function SampleClip( sample:SampleDatas, notes:Array, pads:Array )
		{
			super();
			
			addChildAt( background, 0 );
			pad_txt.mouseEnabled = false;
			note_txt.mouseEnabled = false;
			
			updateSample( sample, notes, pads );
			
			play_btn.addEventListener( MouseEvent.CLICK, playSample );
			delete_btn.addEventListener(MouseEvent.CLICK, deleteSample );
			
			son_txt.doubleClickEnabled = true;
			son_txt.addEventListener(MouseEvent.DOUBLE_CLICK, changeName, false );
			son_txt.addEventListener(MouseEvent.ROLL_OVER, changeCursor );
		}

		private function changeCursor(event:MouseEvent):void
		{
			Mouse.cursor = MouseCursors.MODIFY;
		}

		private function changeName(event:MouseEvent):void
		{
			selectName();
		}
		
		public function selectName():void {
			son_txt.removeEventListener(MouseEvent.ROLL_OVER, changeCursor );
			Mouse.cursor = MouseCursor.AUTO;
			
			stage.focus = son_txt;
			son_txt.type = TextFieldType.INPUT;
			son_txt.selectable = true;
			son_txt.border = true;
			son_txt.borderColor = 0x545C16;
			son_txt.background = true;
			son_txt.backgroundColor = 0xCFD979;
			son_txt.maxChars = 8;
			son_txt.setSelection(0,8);
			
			son_txt.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut );
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyboardDown );
		}
		
		public function disableMouseEvents():void {
			background.disable();
			son_txt.removeEventListener(MouseEvent.ROLL_OVER, changeCursor );			
		}
		
		public function enableMouseEvents():void {
			background.enable();
			son_txt.addEventListener(MouseEvent.ROLL_OVER, changeCursor );			
		}

		private function onKeyboardDown(event:KeyboardEvent):void
		{
			switch( event.keyCode ) {
				case Keyboard.ENTER : 
					if( son_txt.text != "" ) {
						son_txt.text = GLOBAL.renameForMPC( son_txt.text );
						dispatchEvent( new SoundsListingEvent( SoundsListingEvent.CHANGE_SAMPLE_NAME, _sample, null, son_txt.text, true ) );
						removeFocus();
						stage.focus = null;
					}
					break;
				case Keyboard.ESCAPE :
					son_txt.text = _sample.name;
					removeFocus();
					stage.focus = null;
					break;
				case Keyboard.TAB :
					if( son_txt.text != "" ) {
						son_txt.text = GLOBAL.renameForMPC( son_txt.text );
						dispatchEvent( new SoundsListingEvent( SoundsListingEvent.NEXT_SAMPLE, _sample, null, son_txt.text, true ) );
						removeFocus();
					}
					break;
				case Keyboard.F1 :
					playSample();
					break;
			}
		}

		private function onFocusOut(event:FocusEvent):void
		{
			removeFocus();
			son_txt.text = _sample.name;
		}
		
		private function removeFocus() {
			son_txt.type = TextFieldType.DYNAMIC;
			son_txt.selectable = false;
			son_txt.border = false;
			son_txt.background = false;
			son_txt.setSelection(0,0);
			
			son_txt.addEventListener(MouseEvent.ROLL_OVER, changeCursor );
			
			son_txt.removeEventListener(FocusEvent.FOCUS_OUT, onFocusOut );
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyboardDown );
		}
		
		private function playSample(e:MouseEvent=null):void {
			/*if( playSound != null ) {
				playSound( sampleName );
			}*/
			dispatchEvent( new SoundsListingEvent( SoundsListingEvent.PLAY_SAMPLE, _sample, null, "", true ) );
		}
		
		public function renameSampleFromTextField():void {
			sample.name = son_txt.text;
		}
		
		public function disablePlayButton() {
			play_btn.alpha = .2;
			play_btn.disableButton();
			play_btn.removeEventListener( MouseEvent.CLICK, playSample );
		}

		private function deleteSample(event:MouseEvent):void
		{
			/*trace( deleteFunction, "clic delete ", sampleName);
			if( deleteFunction != null ) deleteFunction( sampleName );*/
			
			dispatchEvent( new SoundsListingEvent( SoundsListingEvent.REMOVE_SAMPLE, _sample, null, "", true ) );
		}
		
		public function updateSample( sample:SampleDatas, notes:Array, pads:Array ):void {
			son_txt.text = sample.name;
			sortingName = sample.name;
			
			this.pads = pads;
			//Besoin de ces valeurs pour ordonner le tableau de samples dans SoundsListing
			sortingPads = (pads[0] != null ) ? pads[0].toString() : "-1";
			sortingNotes = (notes[0] != null) ? notes[0].toString() : "-1";
			
			var padsString:String = padsToString( this.pads );
			if( padsString.length < 11 ) pad_txt.text = padsString;
			else pad_txt.text = padsString.slice(0, 8)+"...";
			
			var notesString:String = notes.toString();
			if( notesString.length < 11 )	note_txt.text = notesString;
			else note_txt.text = notesString.slice(0, 8)+"...";
			
			_sample = sample;
			//var pad1:Array = pad_txt.text.split(",");
			//pads = pad_txt.text;
			//pads = transformPadNameIntoNumber( pad1[0] );
			//notes = note_txt.text;
		}
		
		private function padsToString( p:Array ):String {
			var r:Array = new Array();
			for (var j:int = 0; j < p.length; j++) {
				r.push( convertNumberPadsToString( p[j] ) );
			}
			r.sort(Array.CASEINSENSITIVE);
			
			return r.toString();
		}
		
		private function convertNumberPadsToString( numeroPad:int ):String {
			var numeroBank:int = int( numeroPad / 16 );
			var numeroPadInBank:int = 1 + numeroPad % 16;
			if( numeroBank == 0 ) return "A"+numeroPadInBank;
			else if( numeroBank == 1 ) return "B"+numeroPadInBank;
			else if( numeroBank == 2 ) return "C"+numeroPadInBank;
			else if( numeroBank == 3 ) return "D"+numeroPadInBank;
			return "Pas bon";
		}
		
		private function transformPadNameIntoNumber( padName:String ):int {
			var padBank:String = padName.charAt(0);
			var padNumber:int = int( padName.slice(1,3) );
			var mult:int = 0;
			switch( padBank ) {
				case PadBanks.BANK_A :
					mult = 0;
					break;
				case PadBanks.BANK_B :
					mult = 1;
					break;
				case PadBanks.BANK_C :
					mult = 2;
					break;
				case PadBanks.BANK_D :
					mult = 3;
					break;
				default :
					mult = 0;
					break;
			}
			return (padNumber-1) + mult*16;
		} 
		
		public override function toString():String {
			return "[SampleClip sampleName="+_sample.name+" sortingPads="+sortingPads+" sortingNotes="+sortingNotes+"]";
		}

		public function get sample():SampleDatas {
			return _sample;
		}


	}
}