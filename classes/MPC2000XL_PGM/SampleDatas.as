package MPC2000XL_PGM
{
	import UI.PGM_Window;
	
	import de.popforge.audio.output.SoundFactory;
	import de.popforge.format.snd.SndFormat;
	import de.popforge.format.wav.WavFormat;
	
	import flash.desktop.NativeApplication;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class SampleDatas
	{
		private var _filePath:String;
		private var _name:String;
		private var _extension:String;
		private var _sound:Sound;
		private var _channel:SoundChannel;
		private var _isValidSound:Boolean = true;
		private var _soundFileExists:Boolean = true;
		private var _isStereo:Boolean = true;
		
		public function SampleDatas( name:String, filePath:String=null  )
		{
			this._filePath = filePath;
			this._name = name;
			if( filePath ) {
				this._extension = filePath.slice(-3).toLowerCase();
			} else _soundFileExists = false;
		}

		public function playSound() {
			if( _sound == null ) generateSoundFromFilePath();
			else _channel = _sound.play();
		}
		
		public function stopSound() {
			if( _channel != null ) _channel.stop();
		}
		
		private function generateSoundFromFilePath():void 
		{
			if( !_soundFileExists ) {
				throw new Error( "The sound file '"+name+".snd' or '"+name+".wav' doesn't exist." );
			}
			var file:File = new File( filePath );
			if( _extension != "wav" && _extension != "snd" ) throw new Error( "The format is not good. Should be wav or snd and not '"+_extension+"'." );
			
			var byteStream:FileStream = new FileStream();
			byteStream.endian = Endian.LITTLE_ENDIAN;
			
			byteStream.open( file, FileMode.READ );
			
			var bytes:ByteArray = new ByteArray();
			byteStream.readBytes( bytes );
			var loaderContext:LoaderContext = new LoaderContext();
			loaderContext.allowCodeImport = true;
			if( _extension.toLowerCase() == "wav" ) {
				var wav:WavFormat = WavFormat.decode( bytes );
				
				SoundFactory.fromArray( wav.samples, wav.channels, wav.bits, wav.rate, onComplete, loaderContext );
				if( wav.channels == 1 ) _isStereo = false;
				/*try {
					SoundFactory.fromArray( wav.samples, wav.channels, wav.bits, wav.rate, onComplete, loaderContext );
				} catch(e:Error) {
					trace( "il y a erreur sur le sample : "+e.message);
				}*/
			}
			else  {
				var snd:SndFormat = SndFormat.decode( bytes );
				
				SoundFactory.fromArray( snd.samples, snd.channels, snd.bits, snd.rate, onComplete, loaderContext );
				if( snd.channels == 1 ) _isStereo = false;
				/*try {
					SoundFactory.fromArray( snd.samples, snd.channels, snd.bits, snd.rate, onComplete, loaderContext );
				} catch(e:Error) {
					trace( "il y a erreur sur le sample : "+e.message);
				}*/
			}
			
			byteStream.close();
			
		}
		
		private function onComplete( sound:Sound ) 
		{
			_sound = sound;
			_channel = _sound.play();
		}
		
		public function get sound():Sound {
			return _sound;
		}

		public function get filePath():String {
			return _filePath;
		}

		public function get name():String {
			return _name;
		}
		
		public function set name(value:String):void {
			_name = value;
		}
		
		public function get extension():String {
			return _extension;
		}
		
		
		public function get isValidSound():Boolean {
			return _isValidSound;
		}
		
		public function set isValidSound(value:Boolean):void {
			_isValidSound = value;
		}
		
		public function toString():String {
			return "[SampleDatas name="+name+" filePath="+_filePath+"]";
		}


		public function get isStereo():Boolean
		{
			return _isStereo;
		}


	}
}