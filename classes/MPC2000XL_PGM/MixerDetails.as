package MPC2000XL_PGM
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class MixerDetails
	{
		public static const FXSEND_OFF:int = 0;
		public static const FXSEND_M1:int = 1;
		public static const FXSEND_M2:int = 2;
		public static const FXSEND_R1:int = 3;
		public static const FXSEND_R2:int = 4;

		public static const OUT_OFF:int = 0;
		public static const OUT_12:int = 1;
		public static const OUT_34:int = 2;
		public static const OUT_56:int = 3;
		public static const OUT_78:int = 4;
		
		private var _effectLevel:int = 0;
		private var _fxSend:int = 0;
		private var _levelStereoMixer:int = 100;
		private var _pan:int = 50;
		private var _indivLevel:int = 100;
		private var _indivSortie:int = 0;
		
		public function MixerDetails()
		{
		}

		public function writeBytes():ByteArray {
			var b:ByteArray = new ByteArray();
			b.endian = Endian.LITTLE_ENDIAN;
			b.writeByte( _effectLevel );
			b.writeByte( _fxSend );
			b.writeByte( _levelStereoMixer );
			b.writeByte( _pan );
			b.writeByte( _indivLevel );
			b.writeByte( _indivSortie );
			return b;
		}
		
		public function readBytes( byte:ByteArray ):void {
			_effectLevel = byte.readUnsignedByte();
			_fxSend = byte.readUnsignedByte();
			_levelStereoMixer = byte.readUnsignedByte();
			_pan = byte.readUnsignedByte();
			_indivLevel = byte.readUnsignedByte();
			_indivSortie = byte.readUnsignedByte();
		}
		
		public function toString():String {
			return "[MixerDetails effectLevel="+_effectLevel+" fxSend="+_fxSend+"]";
		}

		public function get effectLevel():int {
			return _effectLevel;
		}

		public function set effectLevel(value:int):void {
			_effectLevel = value;
		}

		public function get fxSend():int {
			return _fxSend;
		}

		public function set fxSend(value:int):void {
			_fxSend = value;
		}

		public function get levelStereoMixer():int {
			return _levelStereoMixer;
		}

		public function set levelStereoMixer(value:int):void {
			_levelStereoMixer = value;
		}

		public function get pan():int {
			return _pan;
		}

		public function set pan(value:int):void {
			_pan = value;
		}

		public function get indivLevel():int {
			return _indivLevel;
		}

		public function set indivLevel(value:int):void {
			_indivLevel = value;
		}

		public function get indivSortie():int {
			return _indivSortie;
		}

		public function set indivSortie(value:int):void {
			_indivSortie = value;
		}

	}
}