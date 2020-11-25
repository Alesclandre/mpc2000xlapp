package Interface.Graphics.Pads
{
	import Interface.Menus;
	
	import MPC2000XL_PGM.MPC2000;
	import MPC2000XL_PGM.Pad;
	import MPC2000XL_PGM.PadBanks;
	import MPC2000XL_PGM.SampleDatas;
	
	import events.PadEvent;
	
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeDragManager;
	import flash.display.InteractiveObject;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	import org.moonpalace.display.ToggleClip;

	public class Pad_Interface extends Sprite
	{
		//pads
		public var pad1_mc:InteractivePad;
		public var pad2_mc:InteractivePad;
		public var pad3_mc:InteractivePad;
		public var pad4_mc:InteractivePad;
		public var pad5_mc:InteractivePad;
		public var pad6_mc:InteractivePad;
		public var pad7_mc:InteractivePad;
		public var pad8_mc:InteractivePad;
		public var pad9_mc:InteractivePad;
		public var pad10_mc:InteractivePad;
		public var pad11_mc:InteractivePad;
		public var pad12_mc:InteractivePad;
		public var pad13_mc:InteractivePad;
		public var pad14_mc:InteractivePad;
		public var pad15_mc:InteractivePad;
		public var pad16_mc:InteractivePad;
		public var bankPads:Array;
		//lumières verte de sélection de pads
		public var a_mc,b_mc,c_mc,d_mc:ToggleClip;
		//bouton pour changer de pads
		public var a_btn,b_btn,c_btn,d_btn:SimpleButton;
		
		private var currentBank:String = PadBanks.BANK_A;
		private var startPadIndex:int = 0;
		private var pgm:MPC2000;
		
		public function Pad_Interface()
		{
			bankPads = new Array();
			for (var i:int = 0; i < PadBanks.NBR_PADS; i++) {
				bankPads[i] = this["pad"+(i+1)+"_mc"];
				InteractivePad( bankPads[i] ).addEventListener( NativeDragEvent.NATIVE_DRAG_ENTER, onDraggingOnPad );
			}
			
			
			a_mc.setTo( true );
			
			a_btn.addEventListener( MouseEvent.CLICK, displayPadHandler );
			b_btn.addEventListener( MouseEvent.CLICK, displayPadHandler );
			c_btn.addEventListener( MouseEvent.CLICK, displayPadHandler );
			d_btn.addEventListener( MouseEvent.CLICK, displayPadHandler );
			
			addEventListener( Event.ADDED_TO_STAGE, onAdded ) ;
		}

		private function onAdded(e:Event):void {
			stage.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
			removeEventListener( Event.ADDED_TO_STAGE, onAdded );
		}

		private function onKeyDown(e:KeyboardEvent):void {
			var shortcuts:Array = Application.HOTKEYS;
			
			if( !(stage.focus is TextField) ) {
				for (var i:int = 0; i < shortcuts.length; i++) {
					var keycode:int = shortcuts[i] as int;
					if( e.keyCode == keycode ) {
						InteractivePad( bankPads[i] ).playSound();
						dispatchEvent( new PadEvent( PadEvent.PLAYED, InteractivePad( bankPads[i] ).padID ) );
					}
				}
			}
		}
		
		public function disableSound( sampleName:String ) {
			for (var i:int = 0; i < 16; i++) {
				var pad:InteractivePad = bankPads[i] as InteractivePad;
				if( pad.sampleName == sampleName ) pad.disableSound();
			}
		}
		
		private function onDraggingOnPad(e:NativeDragEvent):void {
			NativeDragManager.acceptDragDrop( InteractiveObject( e.currentTarget ) );
			e.currentTarget.addEventListener( NativeDragEvent.NATIVE_DRAG_DROP, handleDragDrop );
		}
		
		private function handleDragDrop( e:NativeDragEvent ) {
			e.currentTarget.removeEventListener(NativeDragEvent.NATIVE_DRAG_DROP, handleDragDrop );
			
			var files:Array = Clipboard( e.clipboard ).getData( ClipboardFormats.FILE_LIST_FORMAT ) as Array;
			var goodFiles:Array = new Array();
			for (var i:int = 0; i < files.length; i++) {
				var file:File = File( files[i] );
				var ext:String = String( file.extension ).toLowerCase();
				if( ext == "wav" || ext == "snd" ) {
					//var sample:SampleDatas = new SampleDatas( file.name.slice(0,-4), file.nativePath );
					goodFiles.push( file );
				}
			}
			
			var padId:int = InteractivePad( e.currentTarget ).padID;
			dispatchEvent( new PadEvent( PadEvent.UPDATE, padId, goodFiles ) );
		}
		
		private function displayPadHandler(e:MouseEvent):void {
			a_mc.setTo( false );
			b_mc.setTo( false );
			c_mc.setTo( false );
			d_mc.setTo( false );
			switch( e.target ) {
				case a_btn :
					currentBank = PadBanks.BANK_A;
					startPadIndex = 0;
					a_mc.setTo( true );
					break;
				case b_btn :
					currentBank = PadBanks.BANK_B;
					startPadIndex = 16;
					b_mc.setTo( true );
					break;
				case c_btn :
					currentBank = PadBanks.BANK_C;
					startPadIndex = 16*2;
					c_mc.setTo( true );
					break;
				case d_btn :
					currentBank = PadBanks.BANK_D;
					startPadIndex = 16*3;
					d_mc.setTo( true );
					break;
				default :
					currentBank = PadBanks.BANK_A;
					startPadIndex = 0;
					a_mc.setTo( true );
			}
			refreshPads();
		}
		
		
		public function refreshPads( pgm:MPC2000=null ):void 
		{
			if( pgm != null ) this.pgm = pgm;
			
			var pads:Array = this.pgm.pads.tabPads;
			for (var i:int = 0; i < 16; i++) {
				var note:int = Pad( pads[i+startPadIndex] ).numeroNote;
				InteractivePad( bankPads[i] ).update( note, this.pgm.getSampleNameFromNote( note ), null, this.pgm.playSound );
				InteractivePad( bankPads[i] ).padID = i+startPadIndex;
				
				var sampleNumber:int = this.pgm.getSampleNumberFromSampleName( InteractivePad( bankPads[i] ).sampleName );
				if( sampleNumber != -1 && !SampleDatas( this.pgm.samples[ sampleNumber ] ).isValidSound ) InteractivePad( bankPads[i] ).disableSound();
				else InteractivePad( bankPads[i] ).enableSound();
			}
		}
	}
}