package MPC2000XL_PGM
{
	import com.carlcalderon.arthropod.Debug;
	
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class IO_PGM
	{
		private const HEADER:uint = 0x0407;
		private const PADDING:int = 0x00;
		
		public function IO_PGM()
		{
		}
		
		/**
		 * Write the MPC 2000XL parameters in a byteArray in order to send it to a file.
		 * @param program This is the MPC 2000XL parameters included in the program
		 * @return 
		 * 
		 */
		public function writePGM( program:MPC2000 ):ByteArray {
			Debug.log( "IO_PGM > writePGM : program="+program.progName );
			
			var byte:ByteArray = new ByteArray();
			byte.endian = Endian.LITTLE_ENDIAN;
			byte.writeShort(HEADER);
			byte.writeByte(program.getNbreSamples());
			
			var nbreSamples:int = program.getNbreSamples();
			for (var i:int = 0; i < nbreSamples; i++) byte.writeBytes( writeSampleName( SampleDatas( program.samples[i] ).name ) );
			byte.writeBytes( writeProgName(program.progName) );
			byte.writeBytes( writeSliderDetails( program ) );
			for( i=0; i<NoteDatas.NOTE_MAX; i++ ) byte.writeBytes( NoteDatas( program.notes[i] ).writeBytes() );
			for( i=0; i<NoteDatas.NOTE_MAX; i++ ) byte.writeBytes( NoteDatas( program.notes[i] ).mixer.writeBytes() );
			byte.writeShort(0);
			byte.writeByte(0x40);
			byte.writeByte(0);
			byte.writeBytes( program.pads.writeBytes() );
			byte.writeBytes( new Footer() );
			
			return byte;
		}
		
		/**
		 * Read the content of a PGM file.
		 * @param byte This is the input file read by the program
		 * @return 
		 * 
		 */
		public function readPGM( byte:FileStream, folderPath:String ):MPC2000 
		{			
			trace( "IO_PGM > the folderPath path opened is "+folderPath);
			var program:MPC2000 = new MPC2000();
			
			byte.endian = Endian.LITTLE_ENDIAN;
			byte.position = 0;
			var header:uint = byte.readUnsignedShort();
			if( header != HEADER ) throw new Error( "This file has a corrupted header." );
			
			var nbreSamples:int = byte.readUnsignedByte();
			for (var i:int = 0; i < nbreSamples ; i++) {
				byte.readByte();
				var sampleName:String = byte.readUTFBytes( 0x10 );
				sampleName = StringOperations.removeFinalSpaces( sampleName );
				
				var fileSnd:File = new File( folderPath +"/"+sampleName+".snd");
				var fileWav:File = new File( folderPath +"/"+sampleName+".wav");
				if( fileSnd.exists ) program.samples.push( new SampleDatas( sampleName, fileSnd.nativePath ) );
				else if( fileWav.exists )  program.samples.push( new SampleDatas( sampleName, fileWav.nativePath ) );
				else program.samples.push( new SampleDatas( sampleName ) );
				
						
			}
			
			byte.position += 3;
			var nomProg:String = byte.readUTFBytes( 0x10 );
			nomProg = StringOperations.removeFinalSpaces( nomProg );
			program.progName = nomProg;
			
			//Reading the sliders infos
			byte.readByte();
			program.sliderNote = byte.readByte();
			program.sliderTuningLow = byte.readByte();
			program.sliderTuningHigh = byte.readByte();
			program.sliderDecayLow = byte.readByte();
			program.sliderDecayHigh = byte.readByte();
			program.sliderAttackLow = byte.readByte();
			program.sliderAttackHigh = byte.readByte();
			program.sliderFilterLow = byte.readByte();
			program.sliderFilterHigh = byte.readByte();
			program.chanelMidi = byte.readByte();
			
			byte.position += 5;
			//Reading the note parameters infos
			for (i = 0; i < MPC2000.NUMBER_NOTES; i++) {
				var note:NoteDatas = new NoteDatas( 35 + i );
				note.sampleNumber = byte.readUnsignedByte();
				note.mode = byte.readUnsignedByte();
				note.velSW1 = byte.readUnsignedByte();
				note.velSWNote1 = byte.readUnsignedByte();
				note.velSW2 = byte.readUnsignedByte();
				note.velSWNote2 = byte.readUnsignedByte();
				note.voiceOverlap = byte.readUnsignedByte();
				note.padPolyNote1 = byte.readUnsignedByte();
				note.padPolyNote2 = byte.readUnsignedByte();
				note.tune = byte.readShort();
				note.attack = byte.readUnsignedByte();
				note.decay = byte.readUnsignedByte();
				note.decayMode = byte.readUnsignedByte();
				note.frequency = byte.readUnsignedByte();
				note.resonance = byte.readUnsignedByte();
				note.filterAttack = byte.readUnsignedByte();
				note.filterDecay = byte.readUnsignedByte();
				note.filterAmount = byte.readUnsignedByte();
				note.attackVeloLevel = byte.readUnsignedByte();
				note.attackVeloAttack = byte.readUnsignedByte();
				note.attackVeloStart = byte.readUnsignedByte();
				note.filterVeloFreq = byte.readUnsignedByte();
				note.sliderData = byte.readUnsignedByte();
				note.tuneVeloPitch = byte.readUnsignedByte();	
				program.notes[i] = note;
			}
			
			//Reading the mixer details of every note 
			for (i = 0; i < MPC2000.NUMBER_NOTES; i++) {
				NoteDatas( program.notes[i] ).mixer.effectLevel = byte.readUnsignedByte();
				NoteDatas( program.notes[i] ).mixer.fxSend = byte.readUnsignedByte();
				NoteDatas( program.notes[i] ).mixer.levelStereoMixer = byte.readUnsignedByte();
				NoteDatas( program.notes[i] ).mixer.pan = byte.readUnsignedByte();
				NoteDatas( program.notes[i] ).mixer.indivLevel = byte.readUnsignedByte();
				NoteDatas( program.notes[i] ).mixer.indivSortie = byte.readUnsignedByte();
			}
			
			byte.position += 4;
			//Reading the assignation of each pad.
			for( i = 0; i < MPC2000.NUMBER_NOTES; i++ ) Pad( program.pads.tabPads[i] ).numeroNote = byte.readByte();
			
			return program;
		}
		
		public function toString():String {
			return "[Object IO_PGM]";
		}
		
		private function writeSampleName(sampleName:String):ByteArray {
			var b:ByteArray = new ByteArray();
			b.endian = Endian.LITTLE_ENDIAN;
			b.writeByte( PADDING );
			b.writeUTFBytes(sampleName);
			for(var i:int = sampleName.length; i< 0x10; i++ ) {
				b.writeByte( 0x20 );
			}
			return b;
		}
		
		private function writeProgName(progName:String):ByteArray {
			var b:ByteArray = new ByteArray();
			b.endian = Endian.LITTLE_ENDIAN;
			b.writeByte( PADDING );
			b.writeByte( 0x1E );
			b.writeByte( PADDING );
			b.writeUTFBytes(progName);
			for(var i:int = progName.length; i< 0x10; i++ ) {
				b.writeByte( 0x20 );
			}
			return b;
		}
		
		private function writeSliderDetails( program:MPC2000 ):ByteArray {
			var b:ByteArray = new ByteArray();
			b.endian = Endian.LITTLE_ENDIAN;
			b.writeByte( PADDING );
			b.writeByte( program.sliderNote );
			b.writeByte( program.sliderTuningLow );
			b.writeByte( program.sliderTuningHigh );
			b.writeByte( program.sliderDecayLow );
			b.writeByte( program.sliderDecayHigh );
			b.writeByte( program.sliderAttackLow );
			b.writeByte( program.sliderAttackHigh );
			b.writeByte( program.sliderFilterLow );
			b.writeByte( program.sliderFilterHigh );
			b.writeByte( program.chanelMidi );
			b.writeInt(0x19004023);
			b.writeByte(0x00);
			return b;
		}
		
		private function byteToString(b:ByteArray):String {
			var s:String = "length = "+b.length+" : [";
			b.position = 0;
			for( var i:int=0; i<b.length;i++ ) {
				s+=b.readByte().toString(16)+" ";
			}
			s += "]";
			return s;
		}
	}
}