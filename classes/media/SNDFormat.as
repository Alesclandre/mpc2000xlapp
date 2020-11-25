package media
{
	import flash.utils.ByteArray;

	public class SNDFormat implements ISoundFormat
	{
		
		private var _fileName:String;
		private var _level:uint;
		private var _tune:int;
		private var _start:uint;
		private var _loopEnd:uint;
		private var _end:uint;
		private var _loopLength:uint;
		private var _loopMode:Boolean;
		private var _beatsInLoop:uint;
		private var _channels:uint;
		private var _sampleRate:uint;
		private var _byteRate:uint;
		private var _blockAlign:uint;
		private var _bitsPerSample:uint;
		//public var waveDataLength:uint;
		//public var fullDataLength:uint;
		
		public static const HEADER_SIZE:uint = 42;
		
		
		public function SNDFormat()
		{
		}
		
		public function analyzeHeader(byteArray:ByteArray):void {
			var first:uint = byteArray.readUnsignedByte();
			var second:uint = byteArray.readUnsignedByte();
			var isSND:Boolean = first == 1 && second == 4;
			if( !isSND ) throw new Error( "Decode error : incorrect SND Header" );
			
			_fileName = byteArray.readUTFBytes( 0x10 );
			byteArray.position += 0x01;
			_level = byteArray.readUnsignedByte();
			_tune = byteArray.readByte();
			_channels = byteArray.readUnsignedByte() + 1;
			_start = byteArray.readUnsignedInt();
			_loopEnd = byteArray.readUnsignedInt();
			_end = byteArray.readUnsignedInt();
			_loopLength = byteArray.readUnsignedInt();
			_loopMode = (byteArray.readUnsignedByte() == 1);
			_beatsInLoop = byteArray.readUnsignedByte();
			_sampleRate = byteArray.readUnsignedShort();
			
			_bitsPerSample = 16;
			_blockAlign = channels * bitsPerSample / 8;
			
			byteArray.position = 0;
		}
		
		public function getHeaderSize():uint {
			return HEADER_SIZE;
		}
		
		public function toString():String {
			return "[SNDFormat channels="+channels+" sampleRate="+sampleRate+" byteRate="+byteRate+" blockAlign="+blockAlign+" bitsPerSample="+bitsPerSample+" ]";
		}


		public function get fileName():String {
			return _fileName;
		}

		public function get level():uint {
			return _level;
		}

		public function get tune():int {
			return _tune;
		}

		public function get start():uint {
			return _start;
		}

		public function get loopEnd():uint {
			return _loopEnd;
		}

		public function get end():uint {
			return _end;
		}

		public function get loopLength():uint {
			return _loopLength;
		}

		public function get loopMode():Boolean {
			return _loopMode;
		}

		public function get beatsInLoop():uint {
			return _beatsInLoop;
		}

		public function get channels():uint {
			return _channels;
		}

		public function get sampleRate():uint {
			return _sampleRate;
		}

		public function get byteRate():uint {
			return _byteRate;
		}

		public function get blockAlign():uint {
			return _blockAlign;
		}

		public function get bitsPerSample():uint {
			return _bitsPerSample;
		}

	}
}