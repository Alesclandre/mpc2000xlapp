package MPC2000XL_PGM
{
	import events.MPC2000ErrorEvent;
	import events.MPC2000Event;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class MPC2000 extends EventDispatcher
	{
		public static const NUMBER_NOTES:int = 64;
		//Obligé de réduire à 8 et non 16 car de la MPC au Mac (et inversement), 
		//les noms sont tronqués à 8 quoiqu'il arrive.
		
		private const HEADER:uint = 0x0407;
		private const PADDING:int = 0x00;
		
		private var _progName:String = "ALEX";
		private var _sliderNote:int = 0;
		private var _sliderTuningLow:int = 0x88;
		private var _sliderTuningHigh:int = 0x78;
		private var _sliderDecayLow:int = 0x0C;
		private var _sliderDecayHigh:int = 0x2D;
		private var _sliderAttackLow:int = 0;
		private var _sliderAttackHigh:int = 0x14;		
		private var _sliderFilterLow:int = 0xCE;
		private var _sliderFilterHigh:int = 0x32;
		private var _chanelMidi:int = 0;	
		private var _samples:Array;		//Array of sample files
		private var _notes:Array; 		//Array of NoteDatas. Ne peut être statique car plusieurs programmes peuvent être ouverts
		private var _pads:PadBanks; 	//Ensemble des pads. Ne peut être statique.
		private var _pgmFileLoaded:File;

		public function MPC2000()
		{
			samples = new Array();
			notes = new Array();
			for( var i:int = 0; i<NoteDatas.NOTE_MAX; i++ ) {
				notes.push( new NoteDatas(35+i) );
			}
			pads = new PadBanks();
		}
		
		public function getSampleDataFromSampleFilePath( sampleFilePath:String ):SampleDatas {
			for (var i:int = 0; i < _samples.length; i++) {
				var sample:SampleDatas = SampleDatas( _samples[i] );
				if( sample.filePath == sampleFilePath ) return sample;
			}
			return null;
		}
		
		public function getSampleNumberFromSampleName( sampleName:String ):int {
			for (var i:int = 0; i < _samples.length; i++) {
				if( SampleDatas( _samples[i] ).name == sampleName ) return i;
			}
			return -1;
		}		
		
		public function getSampleNumberFromSampleFilePath( filePath:String ):int {
			for (var i:int = 0; i < _samples.length; i++) {
				if( SampleDatas( _samples[i] ).filePath == filePath ) return i;
			}
			return -1;
		}		
		
		public function getSampleNameFromSampleFilePath( filePath:String ):String {
			/*for (var i:int = 0; i < _samples.length; i++) {
				if( SampleDatas( _samples[i] ).filePath == filePath ) return SampleDatas( _samples[i] ).name;
			}
			return null;*/
			var sample:SampleDatas = getSampleDataFromSampleFilePath( filePath );
			return (sample == null ) ? null : sample.name;
		}
		
		public function getSampleDataFromMidiNote( midiNote:int ):SampleDatas {
			var note:NoteDatas = _notes[ midiNote-35 ];
			var sampleNumber:int = note.sampleNumber;
			if( sampleNumber == 0xFF ) return null;
			return SampleDatas( _samples[ sampleNumber ] );
		}
		
		public function getSampleNameFromNote( midiNote:int ):String {
			var sample:SampleDatas = getSampleDataFromMidiNote( midiNote );
			return ( sample != null ) ? sample.name : "";
		}
		
		public function getNotesFromSampleNumber( sampleNumber:int ):Array {
			var notesFromSample:Array = new Array();
			for (var i:int = 0; i < _notes.length; i++) {
				var note:NoteDatas = _notes[i] as NoteDatas;
				if( note.sampleNumber == sampleNumber ) {
					notesFromSample.push( note );
				}
			}
			if( notesFromSample.length == 0 ) return null;
			return notesFromSample;
		}
		
		public function getNotesFromSampleName( sampleName:String ) : Array {
			var sampleNumber:int = getSampleNumberFromSampleName( sampleName );
			return getNotesFromSampleNumber( sampleNumber );
		}
		
		public function getMidiNoteFromPadNumber( padNumber:int ):int {
			return Pad( _pads.tabPads[ padNumber ] ).numeroNote;
		}
		
		public function getNoteDataFromNoteNumber( midiNote:int ):NoteDatas {
			return _notes[ midiNote-35 ];
		}
		
		public function sampleExists( sample:SampleDatas ):Boolean {
			for( var i:int = 0; i<_samples.length ; i++ ) {
				if( /*SampleDatas( _samples[i] ).name == sample.name &&*/ SampleDatas( _samples[i] ).filePath == sample.filePath ) return true;
			}
			return false;
		}
		
		/*public function addSample( sample:String ) {
			if( !sampleExists( sample ) ) {
				_samples.push( sample );
				for (var i:int = 0; i < notes.length; i++) {
					if( NoteDatas( notes[i] ).sampleNumber == 0xFF ) {
						NoteDatas( notes[i] ).sampleNumber = _samples.length - 1;
						break;
					}
				}
				
				dispatchEvent( new MPC2000Event( MPC2000Event.UPDATE,false,false, sample ) );
			}
		}*/
		
		public function addSample( file:File, onPadNumber:int=0 ):SampleDatas 
		{
			var sample:SampleDatas = new SampleDatas( file.name.slice(0,-4), file.nativePath );
			var noteMidi:int = getMidiNoteFromPadNumber( onPadNumber );
			
			//Si le sample existe, il faut lui changer de nom si nécessaire et l'ajouter
			if( !sampleExists( sample ) ) {
				if( _samples.length < 64 ) {
					var tempSample:String = sample.name;
					sample.name = renameSample( sample.name );
					_samples.push( sample );
					var nameHasChanged:Boolean = (sample.name != tempSample);
					if( nameHasChanged ) dispatchEvent( new MPC2000Event( MPC2000Event.SAMPLE_NAME_HAS_CHANGED ) );
					//dispatchEvent( new MPC2000Event( MPC2000Event.ON_SAMPLE_ADDED,false,false, sample, nameHasChanged ) );
				} else {
					dispatchEvent( new IOErrorEvent( IOErrorEvent.IO_ERROR, false, false, "Sorry, you have reached the limit of the MPC 2000 XL." ) );
				}
			}
			
			//Le sample doit être retrouvé par son chemin d'accès, seule donnée qui ne change pas
			var sampleNumber:int = getSampleNumberFromSampleFilePath( sample.filePath );
			
			//Les samples sont ensuite ajoutés selon l'ordre des pads, en commençant par le pad sur lequel a été mis le sample
			if( NoteDatas( _notes[noteMidi-35] ).sampleNumber == 0xFF ) 
				NoteDatas( _notes[noteMidi-35] ).sampleNumber = sampleNumber;
			else {
				//Dans l'ordre des notes
				/*for (var i:int = noteMidi-35; i < notes.length; i++) {
				if( NoteDatas( notes[i] ).sampleNumber == 0xFF ) {
				NoteDatas( notes[i] ).sampleNumber = _samples.length - 1;
				break;
				}
				}*/
				//Dans l'ordre des pads
				for (var i:int = onPadNumber+1; i < _pads.tabPads.length; i++) {
					noteMidi = getMidiNoteFromPadNumber( i );
					if( NoteDatas( _notes[noteMidi-35] ).sampleNumber == 0xFF ) {
						NoteDatas( _notes[noteMidi-35] ).sampleNumber = sampleNumber;
						break;
					}
				}
			}	
			dispatchEvent( new MPC2000Event( MPC2000Event.UPDATE,false,false, sample ) );
			
			return sample;
		}
		
		/**
		 * Change the name of the sample inside the PGM file
		 * @param filePath The filePath of the sample to change
		 * @param newSampleName The new name you want to give to the sample
		 * 
		 */
		public function changeSampleName( filePath:String, newSampleName:String ):void {
			var sample:SampleDatas = getSampleDataFromSampleFilePath( filePath );
			sample.name = newSampleName;
		}
		
		public function isEmpty():Boolean {
			if( _samples.length == 0 ) return true;
			return false;
		}
		
		private function renameSample( sampleName:String ):String {
			var tempName:String = GLOBAL.renameForMPC( sampleName );
			tempName = searchForAGoodName( tempName );
			
			return tempName;			
		}
		
		private function searchForAGoodName( sampleToRename:String ):String 
		{
			var nombre:int = 1;
			if( sampleToRename.slice(-3,-2) == "_" ) nombre = int( sampleToRename.slice( -2 ) ) + 1 ;
			
			var isThere:Boolean = false;
			var lng:int = _samples.length;
			for( var i:int=0; i< lng; i++ ) {
				if( SampleDatas( _samples[i] ).name == sampleToRename ) {
					sampleToRename = sampleToRename.slice(0,-3);
					sampleToRename += "_"+numberToString( nombre );
					nombre++;
					isThere = true;
				}
			}
			
			if( isThere ) sampleToRename = searchForAGoodName( sampleToRename );
			return sampleToRename;
		}
		
		//Fonction pour transformer "1" en "01"
		private function numberToString( n:int ):String {
			if (n>0 && n<=9 ) return "0"+n.toString();
			return n.toString();
		}
		
		public function addSamples( sampleFiles:Array, onPadNumber:int=0 ):Array {
			var sampleDatas:Array = new Array();
			for (var i:int = 0; i < sampleFiles.length; i++) {
				trace("file = "+sampleFiles[i]+" ? "+typeof( sampleFiles[i] ) );
				var sampleData:SampleDatas = addSample( sampleFiles[i], onPadNumber );
				sampleDatas.push( sampleData );
			}
			
			return sampleDatas;
		}
		
		/*public function removeSample( sample:SampleDatas ) {
			var positionSample:int = _samples.length;
			//remove sample from samples array
			for (var i:int = 0; i < _samples.length; i++) {
				if( _samples[i] == sample ) {
					positionSample = i;
					_samples.splice(i,1);
					break;
				}
			}
			
			//update the midi note sample number on the samples above the position, and remove sample from midi note
			for( i=0 ; i< notes.length; i++ ) {
				if( NoteDatas( notes[i] ).sampleNumber == positionSample ) {
					NoteDatas( notes[i] ).sampleNumber = 0xFF;
				}
				if( NoteDatas( notes[i] ).sampleNumber >= positionSample ) {
					NoteDatas( notes[i] ).sampleNumber--;
				}
			}
		}*/
		
		public function removeSampleFromNoteNumber( noteNumber:Number ) {
			var sampleNumber:int = NoteDatas( _notes[ noteNumber-35 ] ).sampleNumber;
			trace("remove sampleNumber: "+sampleNumber+" from note number "+noteNumber);
			var sample:SampleDatas = _samples[ sampleNumber ];
			trace("sample : "+sample );
			
			NoteDatas( _notes[ noteNumber-35 ] ).sampleNumber = 0xFF;
			trace( "remove note number = "+noteNumber +"   "+NoteDatas( _notes[ noteNumber-35 ] ).sampleNumber);
			trace( "sample updated : "+sample);
			
			dispatchEvent( new MPC2000Event( MPC2000Event.UPDATE, false, false, sample ) );
		}
		
		public function removeSample( sampleName:String ) {
			var sampleNumber:int = getSampleNumberFromSampleName( sampleName );
			var sampleRemoved:SampleDatas = _samples[ sampleNumber ];
			//mettre à jour toutes les notes
			for (var i:int = 0; i < NUMBER_NOTES; i++)
			{
				var note:NoteDatas = _notes[i] as NoteDatas;
				//If we find the sample number in all the notes, we remove it
				if( note.sampleNumber == sampleNumber ) note.sampleNumber = 0xFF;
				//All the sample numbers that are higher must be updated on the corresponding notes (sample number is 1 lower)
				else if( note.sampleNumber > sampleNumber && note.sampleNumber != 0xFF ) note.sampleNumber --;
			}
			_samples.splice( sampleNumber, 1);
			
			//dispatchEvent( new MPC2000Event( MPC2000Event.ON_SAMPLE_REMOVED,false,false, sampleRemoved ) );		
			dispatchEvent( new MPC2000Event( MPC2000Event.UPDATE ) );
		}
		
		public function removeSamples( sampleFiles:Array ) {
			for (var i:int = 0; i < sampleFiles.length; i++) {
				removeSample( sampleFiles[i] );
			}
		}
		
		private function stopAllSounds():void {
			var lng:int = samples.length;
			for( var i:int = 0; i<lng; i++ ) {
				SampleDatas( samples[i] ).stopSound();
			}
		}
		
		public function playSound( sampleName:String ) {
			var sampleNumber:int = getSampleNumberFromSampleName( sampleName );
			//SampleDatas( samples[ sampleNumber ] ).sound.play();
			if( sampleNumber != -1 && SampleDatas( samples[ sampleNumber ] ).isValidSound ) {
				try {
					stopAllSounds();
					SampleDatas( samples[ sampleNumber ] ).playSound();
				} catch(e:Error) {
					trace( "pas possible de jouer le son : "+e);
					trace(sampleNumber, samples[ sampleNumber ] );
					SampleDatas( samples[ sampleNumber ] ).isValidSound = false;
					dispatchEvent( new MPC2000ErrorEvent( MPC2000ErrorEvent.NOT_A_VALID_SOUND, false, false, "Impossible to play sound : "+e.message, e.errorID, sampleName ) );
				}
			}
			
		}
		
		public function getNbreSamples():int {
			return _samples.length;
		}
		
		public override function toString():String {
			return "[MPC2000 samples="+samples+" progName="+progName+" notes="+notes+" pads="+pads+"]";
		}


		public function get notes():Array {
			return _notes;
		}

		public function set notes(value:Array):void {
			_notes = value;
		}

		public function get pads():PadBanks {
			return _pads;
		}

		public function set pads(value:PadBanks):void {
			_pads = value;
		}


		public function get progName():String {
			return _progName;
		}

		public function set progName(value:String):void {
			_progName = value;
		}

		public function get sliderNote():int {
			return _sliderNote;
		}

		public function set sliderNote(value:int):void {
			_sliderNote = value;
		}

		public function get sliderTuningLow():int {
			return _sliderTuningLow;
		}

		public function set sliderTuningLow(value:int):void {
			_sliderTuningLow = value;
		}

		public function get sliderTuningHigh():int {
			return _sliderTuningHigh;
		}

		public function set sliderTuningHigh(value:int):void {
			_sliderTuningHigh = value;
		}

		public function get sliderDecayLow():int {
			return _sliderDecayLow;
		}

		public function set sliderDecayLow(value:int):void {
			_sliderDecayLow = value;
		}

		public function get sliderDecayHigh():int {
			return _sliderDecayHigh;
		}

		public function set sliderDecayHigh(value:int):void {
			_sliderDecayHigh = value;
		}

		public function get sliderAttackLow():int {
			return _sliderAttackLow;
		}

		public function set sliderAttackLow(value:int):void {
			_sliderAttackLow = value;
		}

		public function get sliderAttackHigh():int {
			return _sliderAttackHigh;
		}

		public function set sliderAttackHigh(value:int):void {
			_sliderAttackHigh = value;
		}

		public function get sliderFilterLow():int {
			return _sliderFilterLow;
		}

		public function set sliderFilterLow(value:int):void {
			_sliderFilterLow = value;
		}

		public function get sliderFilterHigh():int {
			return _sliderFilterHigh;
		}

		public function set sliderFilterHigh(value:int):void {
			_sliderFilterHigh = value;
		}

		public function get chanelMidi():int {
			return _chanelMidi;
		}

		public function set chanelMidi(value:int):void {
			_chanelMidi = value;
		}

		public function get samples():Array {
			return _samples;
		}

		public function set samples(value:Array):void {
			_samples = value;
		}


		public function get pgmFileLoaded():File {
			return _pgmFileLoaded;
		}

		public function set pgmFileLoaded(value:File):void {
			_pgmFileLoaded = value;
		}


	}
}