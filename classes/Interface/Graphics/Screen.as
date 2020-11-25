package Interface.Graphics
{
	import MPC2000XL_PGM.MPC2000;
	import MPC2000XL_PGM.NoteDatas;
	import MPC2000XL_PGM.Pad;
	import MPC2000XL_PGM.PadBanks;
	import MPC2000XL_PGM.SampleDatas;
	
	import flash.display.MovieClip;
	import flash.text.TextField;
	
	public class Screen extends MovieClip
	{
		public var progName_txt:TextField;
		public var pad_txt:TextField;
		public var note_txt:TextField;
		public var note2_txt:TextField;
		public var sound_txt:TextField;
		public var mode_txt:TextField;
		public var simult_mc:MovieClip;
		public var velo_mc:MovieClip;
		public var stereo_mc:MovieClip;
		
		private var pgm:MPC2000;

		public function Screen()
		{
			super();
			
			simult_mc.visible = false;
			velo_mc.visible = false;
		}
		
		public function init( pgm:MPC2000, padID:int=0 ) 
		{
			this.pgm = pgm;
			update( padID );
		}
		
		public function update( padID:int=0 ) 
		{
			updateName();
			
			var midiNote:int = pgm.getMidiNoteFromPadNumber( padID );
			note_txt.text = note2_txt.text = midiNote.toString();
			
			//trouver le mode
			var noteData:NoteDatas = pgm.getNoteDataFromNoteNumber( midiNote );
			var mode:int = noteData.mode;
			switch( mode ) {
				case NoteDatas.MODE_NORMAL : 
					simult_mc.visible = false;
					velo_mc.visible = false;
					mode_txt.text = "NORMAL";
					break;
				case NoteDatas.MODE_SIMULT : 
					simult_mc.visible = true;
					velo_mc.visible = false;
					mode_txt.text = "SIMULT";
					simult_mc.note1_txt.text = noteData.velSWNote1+"/"+PadBanks.getMPCPadName( pgm.pads.getPadFromNote( noteData.velSWNote1 ) );
					simult_mc.note2_txt.text = noteData.velSWNote2+"/"+PadBanks.getMPCPadName( pgm.pads.getPadFromNote( noteData.velSWNote2 ) );
					break;
				case NoteDatas.MODE_VELSW : 
					simult_mc.visible = false;
					velo_mc.visible = true;
					mode_txt.text = "VEL SW";
					velo_mc.over1_txt.text = noteData.velSW1;
					velo_mc.over2_txt.text = noteData.velSW2;
					velo_mc.note1_txt.text = noteData.velSWNote1+"/"+PadBanks.getMPCPadName( pgm.pads.getPadFromNote( noteData.velSWNote1 ) );
					velo_mc.note2_txt.text = noteData.velSWNote2+"/"+PadBanks.getMPCPadName( pgm.pads.getPadFromNote( noteData.velSWNote2 ) );
					break;
				case NoteDatas.MODE_DCYSW : 
					simult_mc.visible = false;
					velo_mc.visible = true;
					mode_txt.text = "DCY SW";
					velo_mc.over1_txt.text = noteData.velSW1;
					velo_mc.over2_txt.text = noteData.velSW2;
					velo_mc.note1_txt.text = noteData.velSWNote1+"/"+PadBanks.getMPCPadName( pgm.pads.getPadFromNote( noteData.velSWNote1 ) );
					velo_mc.note2_txt.text = noteData.velSWNote2+"/"+PadBanks.getMPCPadName( pgm.pads.getPadFromNote( noteData.velSWNote2 ) );
					break;
			}
			
			pad_txt.text = PadBanks.getMPCPadName( padID );
			
			var sample:SampleDatas = pgm.getSampleDataFromMidiNote( midiNote );
			if( sample == null ) {
				sound_txt.text = "OFF";
				stereo_mc.visible = false;
			} else {
				sound_txt.text = sample.name;
				stereo_mc.visible = sample.isStereo;
			}
			
			
		}
		
		public function updateName():void {
			progName_txt.text = pgm.progName;
		}
	}
}