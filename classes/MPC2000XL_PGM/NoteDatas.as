package MPC2000XL_PGM
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class NoteDatas
	{
		public static const MODE_NORMAL:int = 0;
		public static const MODE_SIMULT:int = 1;
		public static const MODE_VELSW:int = 2;
		public static const MODE_DCYSW:int = 3;
		
		public static const VOICE_POLY:int = 0;
		public static const VOICE_MONO:int = 1;
		public static const VOICE_OFF:int = 2;
		
		public static const DECAY_MODE_END:int = 0;
		public static const DECAY_MODE_START:int = 1;
		
		public static const NOTE_MAX:int = 64;
		
		public var mixer:MixerDetails = new MixerDetails();
		private var _noteNumber:int;
		private var _sampleNumber:int = 0xFF;
		private var _mode:int = 0;
		private var _velSW1:int = 44;
		private var _velSWNote1:int = 0;
		private var _velSW2:int = 88;
		private var _velSWNote2:int = 0;
		private var _voiceOverlap:int = 0;
		private var _padPolyNote1:int = 0;
		private var _padPolyNote2:int = 0;
		private var _tune:int = 0;
		private var _attack:int = 0;
		private var _decay:int = 5;
		private var _decayMode:int = 0;
		private var _frequency:int = 100;
		private var _resonance:int = 0;
		private var _filterAttack:int = 0;
		private var _filterDecay:int = 0;
		private var _filterAmount:int = 0;
		private var _attackVeloLevel:int = 100;
		private var _attackVeloAttack:int = 0;
		private var _attackVeloStart:int = 0;
		private var _filterVeloFreq:int = 0;
		private var _sliderData:int = 0;
		private var _tuneVeloPitch:int = 0;
		
		public function NoteDatas( noteNumber:int = 0 )
		{
			_noteNumber = noteNumber;
			if(_noteNumber == 35) mixer.effectLevel = 6;
		}
		

		public function writeBytes():ByteArray {
			var b:ByteArray = new ByteArray();
			b.endian = Endian.LITTLE_ENDIAN;
			b.writeByte( _sampleNumber );
			b.writeByte( _mode );
			b.writeByte( _velSW1 );
			b.writeByte( _velSWNote1 );
			b.writeByte( _velSW2 );
			b.writeByte( _velSWNote2 );
			b.writeByte( _voiceOverlap );
			b.writeByte( _padPolyNote1 );
			b.writeByte( _padPolyNote2 );
			b.writeShort( _tune );
			b.writeByte( _attack );
			b.writeByte( _decay );
			b.writeByte( _decayMode );
			b.writeByte( _frequency );
			b.writeByte( _resonance );
			b.writeByte( _filterAttack );
			b.writeByte( _filterDecay );
			b.writeByte( _filterAmount );
			b.writeByte( _attackVeloLevel );
			b.writeByte( _attackVeloAttack );
			b.writeByte( _attackVeloStart );
			b.writeByte( _filterVeloFreq );
			b.writeByte( _sliderData );
			b.writeByte( _tuneVeloPitch );
			return b;
		}
		
		public function readBytes( byte:ByteArray ):void {
			byte.position = 0;
			_sampleNumber = byte.readUnsignedByte();
			_mode = byte.readUnsignedByte();
			_velSW1 = byte.readUnsignedByte();
			_velSWNote1 = byte.readUnsignedByte();
			_velSW2 = byte.readUnsignedByte();
			_velSWNote2 = byte.readUnsignedByte();
			_voiceOverlap = byte.readUnsignedByte();
			_padPolyNote1 = byte.readUnsignedByte();
			_padPolyNote2 = byte.readUnsignedByte();
			_tune = byte.readShort();
			_attack = byte.readUnsignedByte();
			_decay = byte.readUnsignedByte();
			_decayMode = byte.readUnsignedByte();
			_frequency = byte.readUnsignedByte();
			_resonance = byte.readUnsignedByte();
			_filterAttack = byte.readUnsignedByte();
			_filterDecay = byte.readUnsignedByte();
			_filterAmount = byte.readUnsignedByte();
			_attackVeloLevel = byte.readUnsignedByte();
			_attackVeloAttack = byte.readUnsignedByte();
			_attackVeloStart = byte.readUnsignedByte();
			_filterVeloFreq = byte.readUnsignedByte();
			_sliderData = byte.readUnsignedByte();
			_tuneVeloPitch = byte.readUnsignedByte();
		}
		
		public function toString():String {
			return "[NoteDatas noteNumber="+_noteNumber+" sampleNumber="+_sampleNumber+" mixer="+mixer.toString()+"]";
		}
		
		public function get noteNumber():int {
			return _noteNumber;
		}

		public function get sampleNumber():int {
			return _sampleNumber;
		}

		public function set sampleNumber(value:int):void {
			_sampleNumber = value;
		}


		public function get mode():int {
			return _mode;
		}

		public function set mode(value:int):void {
			_mode = value;
		}

		public function get velSW1():int {
			return _velSW1;
		}

		public function set velSW1(value:int):void {
			_velSW1 = value;
		}

		public function get velSWNote1():int {
			return _velSWNote1;
		}

		public function set velSWNote1(value:int):void {
			_velSWNote1 = value;
		}

		public function get velSW2():int {
			return _velSW2;
		}

		public function set velSW2(value:int):void {
			_velSW2 = value;
		}

		public function get velSWNote2():int {
			return _velSWNote2;
		}

		public function set velSWNote2(value:int):void {
			_velSWNote2 = value;
		}

		public function get voiceOverlap():int {
			return _voiceOverlap;
		}

		public function set voiceOverlap(value:int):void {
			_voiceOverlap = value;
		}

		public function get padPolyNote1():int {
			return _padPolyNote1;
		}

		public function set padPolyNote1(value:int):void {
			_padPolyNote1 = value;
		}

		public function get padPolyNote2():int {
			return _padPolyNote2;
		}
		
		public function set padPolyNote2(value:int):void {
			_padPolyNote2 = value;
		}
		
		public function get tune():int {
			return _tune;
		}

		public function set tune(value:int):void {
			_tune = value;
		}

		public function get attack():int {
			return _attack;
		}

		public function set attack(value:int):void {
			_attack = value;
		}

		public function get decay():int {
			return _decay;
		}

		public function set decay(value:int):void {
			_decay = value;
		}

		public function get decayMode():int {
			return _decayMode;
		}

		public function set decayMode(value:int):void {
			_decayMode = value;
		}

		public function get frequency():int {
			return _frequency;
		}

		public function set frequency(value:int):void {
			_frequency = value;
		}

		public function get resonance():int {
			return _resonance;
		}

		public function set resonance(value:int):void {
			_resonance = value;
		}

		public function get filterAttack():int {
			return _filterAttack;
		}

		public function set filterAttack(value:int):void {
			_filterAttack = value;
		}

		public function get filterDecay():int {
			return _filterDecay;
		}

		public function set filterDecay(value:int):void {
			_filterDecay = value;
		}

		public function get filterAmount():int {
			return _filterAmount;
		}

		public function set filterAmount(value:int):void {
			_filterAmount = value;
		}

		public function get attackVeloLevel():int {
			return _attackVeloLevel;
		}

		public function set attackVeloLevel(value:int):void {
			_attackVeloLevel = value;
		}

		public function get attackVeloAttack():int {
			return _attackVeloAttack;
		}

		public function set attackVeloAttack(value:int):void {
			_attackVeloAttack = value;
		}

		public function get attackVeloStart():int {
			return _attackVeloStart;
		}

		public function set attackVeloStart(value:int):void {
			_attackVeloStart = value;
		}

		public function get filterVeloFreq():int {
			return _filterVeloFreq;
		}

		public function set filterVeloFreq(value:int):void {
			_filterVeloFreq = value;
		}

		public function get sliderData():int {
			return _sliderData;
		}

		public function set sliderData(value:int):void {
			_sliderData = value;
		}

		public function get tuneVeloPitch():int {
			return _tuneVeloPitch;
		}

		public function set tuneVeloPitch(value:int):void {
			_tuneVeloPitch = value;
		}


	}
}