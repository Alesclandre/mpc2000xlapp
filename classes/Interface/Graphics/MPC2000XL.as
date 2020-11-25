package Interface.Graphics
{
	import Interface.Graphics.Messages.ErrorNameBox;
	import Interface.Graphics.Messages.MessageBox;
	import Interface.Graphics.Messages.ReplaceBox;
	import Interface.Graphics.Pads.InteractivePad;
	import Interface.Graphics.Pads.Pad_Interface;
	import Interface.Graphics.SampleList.BackgroundSampleClip;
	import Interface.Graphics.SampleList.SampleClip;
	import Interface.Graphics.SampleList.SoundsListing;
	import Interface.Menus;
	
	import MPC2000XL_PGM.GLOBAL;
	import MPC2000XL_PGM.MPC2000;
	import MPC2000XL_PGM.NoteDatas;
	import MPC2000XL_PGM.Pad;
	import MPC2000XL_PGM.PadBanks;
	import MPC2000XL_PGM.SampleDatas;
	
	import UI.MouseCursors;
	import UI.PGM_Window;
	
	import commandPattern.commands.IUndoableCommand;
	import commandPattern.commands.LoadSoundsCommand;
	
	import events.MPC2000ErrorEvent;
	import events.MPC2000Event;
	import events.PadEvent;
	import events.SoundsListingEvent;
	
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeDragManager;
	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.NativeDragEvent;
	import flash.events.SampleDataEvent;
	import flash.filesystem.File;
	import flash.filters.GlowFilter;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	
	import gs.TweenLite;
	import gs.easing.Strong;
	
	import media.SoundGenerator;
	
	import org.moonpalace.display.ToggleClip;
	
	public class MPC2000XL extends MovieClip
	{
		public var listing_mc:SoundsListing;
		public var pads_mc:Pad_Interface;
		public var screen_mc:Screen;
		//pads
		/*public var pad1_mc:InteractivePad;
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
		public var a_mc:ToggleClip;
		public var b_mc:ToggleClip;
		public var c_mc:ToggleClip;
		public var d_mc:ToggleClip;
		//bouton pour changer de pads
		public var a_btn:SimpleButton;
		public var b_btn:SimpleButton;
		public var c_btn:SimpleButton;
		public var d_btn:SimpleButton;*/
		
		private var _pgm:MPC2000;
		private var _window:PGM_Window;
		private var currentBank:String = PadBanks.BANK_A;
		
		private var fileGraph:MovieClip = new SoundFileGraph();
		private var isSampleDragged:Boolean = false;
		private var isOverPadID:int = -1;
		private var sampleToReplace:SampleDatas;
		private var padToReplace:int;
		private var samplesDragged:Array = new Array();
		
		public function MPC2000XL( window:PGM_Window )
		{
			super();
			this._window = window;
			
			tabChildren = false;
			/*bankPads = new Array();
			for (var i:int = 0; i < PadBanks.NBR_PADS; i++) {
				bankPads[i] = this["pad"+(i+1)+"_mc"];
				InteractivePad( bankPads[i] ).removeSampleCallback = removeSampleFromPad;
				InteractivePad( bankPads[i] ).addEventListener( NativeDragEvent.NATIVE_DRAG_ENTER, onDraggingOnPad );
			}*/
			//listing_mc.addEventListener( NativeDragEvent.NATIVE_DRAG_ENTER, onDraggingOnPad );
			
			listing_mc.addEventListener( SoundsListingEvent.ADD_SAMPLES, onSamplesAddedOnList );
			listing_mc.addEventListener( SoundsListingEvent.REMOVE_SAMPLE, onSampleDeleted );
			listing_mc.addEventListener( SoundsListingEvent.PLAY_SAMPLE, onSamplePlayed );
			listing_mc.addEventListener( SoundsListingEvent.CHANGE_SAMPLE_NAME, OnSampleNameChanged );
			listing_mc.addEventListener( SoundsListingEvent.NEXT_SAMPLE, onNextSample );
			
			pads_mc.addEventListener( PadEvent.UPDATE, onPadUpdate );
			pads_mc.addEventListener( PadEvent.REMOVE_NOTE, onNoteRemovedOnPad, true );
			pads_mc.addEventListener( MouseEvent.ROLL_OVER, onPadsOver, true );
			pads_mc.addEventListener( MouseEvent.ROLL_OUT, onPadsOut, true );
			
			addEventListener( SoundsListingEvent.DRAGGED, onSampleDragged, true );
			addEventListener( SoundsListingEvent.DRAG_STOPPED, onSampleDragStopped, true );
			
			addEventListener( PadEvent.PLAYED, onPadPlayed, true );
			
			addEventListener( Event.ADDED_TO_STAGE, onAdded );
			
			
			/*a_mc.setTo( true );
			updatePadIDs();
			
			a_btn.addEventListener( MouseEvent.CLICK, displayPadHandler );
			b_btn.addEventListener( MouseEvent.CLICK, displayPadHandler );
			c_btn.addEventListener( MouseEvent.CLICK, displayPadHandler );
			d_btn.addEventListener( MouseEvent.CLICK, displayPadHandler );*/
			
			trace("MPC2000XL constructor");
		}

		private function onPadPlayed(event:PadEvent):void
		{
			screen_mc.update( event.padId );
		}

		private function onAdded(e:Event):void
		{
			
		}
		
		private function addSampleOnPad( sample:SampleDatas, padID:int ) {
			trace("j'ai ajouté "+sample+" au pad "+padID);
			pgm.addSample( new File( sample.filePath ), padID );
			refreshAll();
		}

		private function onPadsOver(e:MouseEvent):void {
			var pad:InteractivePad;
			if( e.target is InteractivePad ) pad = InteractivePad( e.target );
			else if( e.target is MovieClip && e.target.name == "fond_mc" ) pad = InteractivePad( e.target.parent );
			
			if( pad!= null && isSampleDragged) {
				isOverPadID = pad.padID;
			} else isOverPadID = -1;
		}
		
		private function onPadsOut(e:MouseEvent):void {
			isOverPadID = -1;
		}

		private function onSampleDragged(e:SoundsListingEvent):void {
			trace("le sample "+e.sample.name+" est draggué");	
			listing_mc.disableAllMouseEvents();
			Mouse.cursor = MouseCursors.CLOSED_HAND;
			
			fileGraph.x = this.mouseX;
			fileGraph.y = this.mouseY;
			fileGraph.alpha = 0;
			fileGraph.rotation = 45;
			fileGraph.scaleX = fileGraph.scaleY = .7;
			fileGraph.mouseEnabled = false;
			addChild( fileGraph );
			fileGraph.startDrag();
			TweenLite.to( fileGraph, .3, {alpha:.6, scaleX:1, scaleY:1, rotation:0} );
			
			isSampleDragged = true;
			samplesDragged.push( e.sample );
		}
		
		private function onSampleDragStopped(e:SoundsListingEvent):void {
			trace("le sample "+e.sample.name+" est stoppé dans sa drague sur le padID n°"+isOverPadID);
			fileGraph.stopDrag();
			if( fileGraph.stage != null ) TweenLite.to( fileGraph, .2, {alpha:0, scaleX:.5, scaleY:.5, rotation:-30, onComplete:removeChild, onCompleteParams:[fileGraph]} );
			//if( fileGraph.stage != null ) removeChild( fileGraph );
			listing_mc.enableAllMouseEvents();
			
			if( isOverPadID != -1 ) {
				//Verify if a sample already exists on the pad
				var noteNumber:int = pgm.pads.getNoteOnPad( isOverPadID );	
				if( pgm.getSampleNameFromNote( noteNumber ) != "" ) {
					var replaceBox:ReplaceBox = showReplaceBox();
					sampleToReplace = e.sample;
					padToReplace = isOverPadID;
					replaceBox.addEventListener( Event.CHANGE, onReplace );
				} else {
					addSampleOnPad( e.sample, isOverPadID );
					screen_mc.update( isOverPadID );
				}
			}
			
			isSampleDragged = false;
			samplesDragged = null;
			samplesDragged = new Array();
		}

		private function onReplace(event:Event):void
		{
			removeSampleFromPad( padToReplace );
			addSampleOnPad( sampleToReplace, padToReplace );
			screen_mc.update( padToReplace );
		}

		private function onNextSample(e:SoundsListingEvent):void {
			if( listing_mc.thereIsAnotherName( e.sample, e.newName ) ) {
				showMessageBox( "The name '"+e.newName+"' already exists. Please choose another name." );
				listing_mc.selectName( e.sample );
			} else {
				listing_mc.renameSampleFromTextField( e.sample );
				pads_mc.refreshPads();
				listing_mc.selectNextSample( e.sample );
			}
		}

		private function OnSampleNameChanged(e:SoundsListingEvent):void {
			trace("change smaple name = "+e.sample.name );
			if( listing_mc.thereIsAnotherName( e.sample, e.newName ) ) {
				showMessageBox( "The name '"+e.newName+"' already exists. Please choose another name." );
				listing_mc.selectName( e.sample );
			} else {
				listing_mc.renameSampleFromTextField( e.sample );
				pads_mc.refreshPads();
			}
		}
		
		private function onSamplePlayed(event:SoundsListingEvent):void
		{
			pgm.playSound( event.sample.name );
		}

		private function onSampleDeleted(event:SoundsListingEvent):void
		{
			pgm.removeSample( event.sample.name );
			listing_mc.removeSample( event.sample );
			pads_mc.refreshPads();
		}

		private function onSamplesAddedOnList(event:SoundsListingEvent):void
		{
			var command:IUndoableCommand = new LoadSoundsCommand( event.sampleFiles, window );
			command.execute();
			
			/*var sampleDatas:Array = pgm.addSamples( event.sampleFiles );
			refreshListing();
			pads_mc.refreshPads();*/
		}
		
		public function initMPCwithPGM( pgm:MPC2000 ) {
			trace("MPC init");
			this._pgm = pgm;
			pads_mc.refreshPads( pgm );	
			listing_mc.destroyAll();
			listing_mc.init();
			refreshListing();
			screen_mc.init( pgm );
			pgm.addEventListener( MPC2000Event.SAMPLE_NAME_HAS_CHANGED, onSampleNameChanged );
			/*pgm.addEventListener( MPC2000Event.ON_SAMPLE_ADDED, onSampleAdded );
			pgm.addEventListener( MPC2000Event.ON_SAMPLE_REMOVED, onSampleRemoved );
			//pgm.addEventListener( MPC2000Event.UPDATE, update );*/
			pgm.addEventListener( IOErrorEvent.IO_ERROR, onError );
			pgm.addEventListener( ErrorEvent.ERROR, onError );
			pgm.addEventListener( MPC2000ErrorEvent.NOT_A_VALID_SOUND, onError );
		}
		
		private function onNoteRemovedOnPad(event:PadEvent):void
		{
			trace("on note removed on pad "+event.currentTarget, event.target);
			removeSampleFromPad( event.padId );	
		}
		
		private function onPadUpdate(event:PadEvent):void
		{
			/*var samples:Array = new Array();
			for( var i:int = 0;i<event.files.length;i++) {
				var file:File = File( event.files[i] );
				samples.push( file );
			}
			pgm.addSamples( samples, event.padId );
			
			for(  i = 0;i<event.files.length;i++) {
				trace("******* samples   = "+File( samples[i] ).name);
				trace("******* eventFiles   = "+File( event.files[i]).name);
			}
			
			pads_mc.refreshPads();
			refreshListing();/*/
			var command:IUndoableCommand = new LoadSoundsCommand( event.files, window, event.padId );
			command.execute();
			
		}
		
		public function refreshAll() {
			pads_mc.refreshPads();
			refreshListing();
		}
		
		public function isEmpty():Boolean {
			return pgm.isEmpty();
		}
		
		private function removeSampleFromPad( pad_ID:Number ) {
			var noteNumber:int = pgm.pads.getNoteOnPad( pad_ID );			
			pgm.removeSampleFromNoteNumber( noteNumber );
			refreshAll();
		}

		/*private function onSampleRemoved(event:MPC2000Event):void
		{
			var sampleName:String = SampleDatas( event.newSample ).name;
			listing_mc.removeSample( sampleName );
			pads_mc.refreshPads();
		}*/
		
		private function onError(e:ErrorEvent):void {
			showMessageBox( e.text );
			if( e.type == MPC2000ErrorEvent.NOT_A_VALID_SOUND ) {
				var sample:SampleClip = listing_mc.getSampleClipFromsampleName( MPC2000ErrorEvent( e ).sampleName );
				sample.disablePlayButton();		
				
				/*for (var i:int = 0; i < bankPads.length; i++) {
					var pad:InteractivePad = bankPads[i] as InteractivePad;
					if( pad.sampleName == MPC2000ErrorEvent( e ).sampleName ) pad.disableSound();
				}*/
				pads_mc.disableSound( MPC2000ErrorEvent( e ).sampleName );
			}
		}
		
		private function onSampleNameChanged(e:MPC2000Event):void {
			trace("sampleName Changed");
			
			showMessageBox( "Some of your sound files have been renamed because of the MPC constraints.\n" +
				"A name should be less than "+GLOBAL.MAX_TEXT_LENGTH+" characters, and should not contain special characters.\n" +
				"If you choose to save with the sound files, these files will be copied and renamed." );
		}

		/*private function onSampleAdded(e:MPC2000Event):void {
			trace("sample added");
			var sample:SampleDatas = e.newSample;
			listing_mc.addSample(sample.name);	
			
			if( e.sampleNameHasChanged ) showMessageBox( "Some of your sound files have been renamed because of the MPC constraints.\n" +
				"A name should be less than 16 characters, and less than 8 characters in order to be read correctly, and should not contain special characters.\n" +
				"If you choose to save with the sound files, these files will be copied and renamed." );
		}
		
		private function update(e:MPC2000Event) {
			trace( "interface update " +e.newSample);
			if( e.newSample != null ) {
				var sample:SampleDatas = e.newSample;
				var notesAndPads:Object = getNotesAndPadsFromSampleName( sample.name );
				
				listing_mc.updateSample(sample.name , notesAndPads.notes , notesAndPads.pads );
			}
			
			pads_mc.refreshPads( pgm );
			//displaySamplesOnListing();
		}*/
		
		public function showMessageBox( text:String ):MessageBox {
			var messageBoxAlreadyExists:Boolean = false;
			var message:MessageBox;
			for( var i:int=0; i<numChildren ;i++ ) {
				if( (getChildAt( i ) is MessageBox) ) {
					message = MessageBox( getChildAt( i ) );
					message.update( text );
					messageBoxAlreadyExists = true;
					break;
				}
			}
			if( !messageBoxAlreadyExists ) {
				message = new MessageBox( text );
				message.x = int( ( stage.stageWidth ) / 2 );
				message.y = int( ( stage.stageHeight ) / 2 );
				message.filters = [new GlowFilter(0,.5, 19,19, 2, 2) ];
				addChild( message );
				TweenLite.from( message, .5, {alpha: .6, scaleX:.9, scaleY:.9, ease: Strong.easeOut} );
			}
			
			return message;
		}	
		
		public function removeMessageBox( message:MessageBox ):void {
			if( message != null && message.stage != null ) message.close();
		}
		
		public function showErrorBox():ErrorNameBox {
			var error:ErrorNameBox = new ErrorNameBox();
			error.x = int( ( stage.stageWidth ) / 2 );
			error.y = int( ( stage.stageHeight ) / 2 );
			error.filters = [new GlowFilter(0,.5, 19,19, 2, 2) ];
			addChild( error );
			TweenLite.from( error, .5, {alpha: .6, scaleX:.9, scaleY:.9, ease: Strong.easeOut, onComplete:function(){ error.scaleX = error.scaleY = 1;} } );
			
			return error;
		}		
		
		public function removeErrorBox( error:ErrorNameBox ):void {
			if( error != null && error.stage != null ) error.close();
		}
		
		public function showReplaceBox():ReplaceBox {
			var replaceBox:ReplaceBox = new ReplaceBox();
			replaceBox.x = int( ( stage.stageWidth ) / 2 );
			replaceBox.y = int( ( stage.stageHeight ) / 2 );
			replaceBox.filters = [new GlowFilter(0,.5, 19,19, 2, 2) ];
			addChild( replaceBox );
			TweenLite.from( replaceBox, .5, {alpha: .6, scaleX:.9, scaleY:.9, ease: Strong.easeOut, onComplete:function(){ replaceBox.scaleX = replaceBox.scaleY = 1;} } );
			
			return replaceBox;
		}		
		
		public function removeReplaceBox( replaceBox:ReplaceBox ):void {
			if( replaceBox != null && replaceBox.stage != null ) replaceBox.close();
		}
	
		/*private function onDraggingOnPad(e:NativeDragEvent):void {
			NativeDragManager.acceptDragDrop( InteractiveObject( e.currentTarget ) );
			e.currentTarget.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, handleDragDrop );
		}
		
		private function handleDragDrop(e:NativeDragEvent):void {
			e.currentTarget.removeEventListener(NativeDragEvent.NATIVE_DRAG_DROP, handleDragDrop );
			
			var files:Array = Clipboard( e.clipboard ).getData( ClipboardFormats.FILE_LIST_FORMAT ) as Array;
			var goodSamples:Array = new Array();
			for (var i:int = 0; i < files.length; i++) {
				var file:File = File( files[i] );
				var ext:String = String( file.extension ).toLowerCase();
				if( ext == "wav" || ext == "snd" ) {
					var sample:SampleDatas = new SampleDatas( file.name.slice(0,-4), file.nativePath );
					goodSamples.push( sample );
				}
			}
			
			if( e.currentTarget == listing_mc ) pgm.addSamples( goodSamples );
			else {
				pgm.addSamples( goodSamples, InteractivePad( e.currentTarget ).padID );
			}
		}*/

		/*private function displayPadHandler(e:MouseEvent):void {
			a_mc.setTo( false );
			b_mc.setTo( false );
			c_mc.setTo( false );
			d_mc.setTo( false );
			switch( e.target ) {
				case a_btn :
					currentBank = PadBanks.BANK_A;
					refreshPads();
					a_mc.setTo( true );
					break;
				case b_btn :
					currentBank = PadBanks.BANK_B;
					refreshPads();
					b_mc.setTo( true );
					break;
				case c_btn :
					currentBank = PadBanks.BANK_C;
					refreshPads();
					c_mc.setTo( true );
					break;
				case d_btn :
					currentBank = PadBanks.BANK_D;
					refreshPads();
					d_mc.setTo( true );
					break;
				default :
					currentBank = PadBanks.BANK_A;
					refreshPads();
					a_mc.setTo( true );
			}
			updatePadIDs();
		}
		
		private function updatePadIDs():void {
			for (var i:int = 0; i < bankPads.length; i++) {
				var pad:InteractivePad = bankPads[i] as InteractivePad;
				
				if( a_mc.isOn ) pad.padID = i;
				else if( b_mc.isOn ) pad.padID = i+16;
				else if( c_mc.isOn ) pad.padID = i+16*2;
				else if( d_mc.isOn ) pad.padID = i+16*3;
			}
		}
		
		private function refreshPads():void {
			var tab:Array = pgm.pads.getSamplesOnPadBank( currentBank );
			for (var i:int = 0; i < tab.length; i++) {
				var note:int = Pad( tab[i] ).numeroNote;
				InteractivePad( bankPads[i] ).update( note, pgm.getSampleNameFromNote( note ), null, pgm.playSound );
				
				var sampleNumber:int = pgm.getSampleNumberFromSampleName( InteractivePad( bankPads[i] ).sampleName );
				if( sampleNumber != -1 && !SampleDatas( pgm.samples[ sampleNumber ] ).isValidSound ) InteractivePad( bankPads[i] ).disableSound();
				else InteractivePad( bankPads[i] ).enableSound();
			}
		}*/

		private function playSound(e:Event):void {
			SoundGenerator( e.target ).play();
		}
		
		private function refreshListing() {
			listing_mc.setPGM( pgm );
			var lng:int = pgm.samples.length;
			for (var i:int = 0; i < lng; i++) {
				var sample:SampleDatas = SampleDatas( pgm.samples[i] );
				/*var notes:Array = pgm.getNotesFromSampleName( sampleName );
				var pads:Array = new Array();
				for (var j:int = 0; j < notes.length; j++) {
					notes[j] = NoteDatas( notes[j] ).noteNumber;
					pads.push( convertNumberPadsToString( pgm.pads.getPadFromNote( notes[j] ) ) );
				}
				listing_mc.addSample(sampleName , notes.toString() , pads.toString() );*/
				var notesAndPads:Object = getNotesAndPadsFromSampleName( sample.name );
				
				if( listing_mc.isSampleInListing( sample.name ) ) {
					listing_mc.updateSample( sample , notesAndPads.notes , notesAndPads.pads );
				} else 
					listing_mc.addSample(sample , notesAndPads.notes , notesAndPads.pads );
			}
			listing_mc.update();
			//listing_mc.init();
		}
		
		public function getNotesAndPadsFromSampleName( sampleName:String ) : Object {
			var noteDatas:Array = pgm.getNotesFromSampleName( sampleName );
			trace("getnotes from "+sampleName+" : notes = "+notes);
			var pads:Array = new Array();
			var notes:Array = new Array();
			if( noteDatas != null ) {
				for (var j:int = 0; j < noteDatas.length; j++) {
					notes[j] = NoteDatas( noteDatas[j] ).noteNumber;
					pads.push(  pgm.pads.getPadFromNote( notes[j] ) );
				}
				pads.sort(Array.CASEINSENSITIVE);
			}
			
			return {notes: notes, pads: pads};
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


		public function get pgm():MPC2000 {
			return _pgm;
		}


		public function get window():PGM_Window {
			return _window;
		}


	}
}