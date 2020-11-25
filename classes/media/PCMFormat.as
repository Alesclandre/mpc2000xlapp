/**
* PCMFormat by Denis Kolyako. May 28, 2007
* Visit http://dev.etcs.ru for documentation, updates and more free code.
*
* You may distribute this class freely, provided it is not modified in any way (including
* removing this header or changing the package path).
* 
*
* Please contact etc[at]mail.ru prior to distributing modified versions of this class.
*/
package media {
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	public class PCMFormat implements ISoundFormat {
		
		/*
		* *********************************************************
		* CLASS PROPERTIES
		* *********************************************************
		*
		*/
		private var _channels:uint;
		private var _sampleRate:uint;
		private var _byteRate:uint;
		private var _blockAlign:uint;
		private var _bitsPerSample:uint;
		private var _waveDataLength:uint;
		private var _fullDataLength:uint;
		private var _numSamples:uint;

		
		public static const HEADER_SIZE:uint = 44;
		
		/*
		* *********************************************************
		* CONSTRUCTOR
		* *********************************************************
		*
		*/
		public function PCMFormat() {
			
		}
		
		/*
		* *********************************************************
		* PUBLIC METHODS
		* *********************************************************
		*
		*/
		public function analyzeHeader(byteArray:ByteArray):void {
			var typeArray:ByteArray = new ByteArray();
			byteArray.readBytes(typeArray,0,4);
			
			if (typeArray.toString() != 'RIFF') {
				throw new Error("Decode error: incorrect RIFF header");
				return;
			}
			
			_fullDataLength = byteArray.readUnsignedInt()+8;
			byteArray.position = 0x10;
			var chunkSize:Number = byteArray.readUnsignedInt();
			
			if (chunkSize != 0x10) {
				throw new Error("Decode error: incorrect chunk size");
				return;
			}
			
			var isPCM:Boolean = Boolean(byteArray.readShort());
			
			if (!isPCM) {
				throw new Error("Decode error: this file is not PCM wave file");
				return;
			}
			
			_channels = byteArray.readShort();
			_sampleRate = byteArray.readUnsignedInt();
			
			/*switch (sampleRate) {
				case 48000:
				case 44100:
				case 22050:
				case 11025:
				case 5512:
				break;
				default:
				throw new Error("Decode error: incorrect sample rate");
				return;
			}*/
			
			_byteRate = byteArray.readUnsignedInt();
			_blockAlign = byteArray.readShort();
			_bitsPerSample = byteArray.readShort();
			byteArray.position += 0x04;
			_waveDataLength = byteArray.readUnsignedInt();
			
			if (!blockAlign) {
				_blockAlign = channels*bitsPerSample/8;
			}
			
			_numSamples = waveDataLength * 8 / (channels * bitsPerSample);

			byteArray.position = 0;
		}
		
		public function getHeaderSize():uint {
			return HEADER_SIZE;
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
		
		public function get waveDataLength():uint {
			return _waveDataLength;
		}
		
		public function get fullDataLength():uint {
			return _fullDataLength;
		}
		
		public function get numSamples():uint {
			return _numSamples;
		}
		
		public function toString():String {
			return "[PCMFormat channels="+channels+" sampleRate="+sampleRate+" byteRate="+byteRate+" blockAlign="+blockAlign+" bitsPerSample="+bitsPerSample+" waveDataLength="+waveDataLength+" ]";
		}
	}
}