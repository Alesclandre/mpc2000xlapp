package media
{
	import de.popforge.audio.output.SoundFactory;
	import de.popforge.format.wav.WavFormat;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.media.Sound;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class SoundGenerator2
	{
		private var extension:String;
		private var byteStream:FileStream;
		private var sound:Sound;

		public function SoundGenerator2( filePath:String=null ) {
			var file:File = new File( filePath );
			super();
			extension = filePath.slice(-3).toLowerCase();
			trace( extension );
			if( extension != "wav" && extension != "snd" ) throw new Error( "The format is not good. Should be wav or snd" );
			
			byteStream = new FileStream();
			byteStream.endian = Endian.LITTLE_ENDIAN;
			
			byteStream.open( file, FileMode.READ );
			
			var bytes:ByteArray = new ByteArray();
			byteStream.readBytes( bytes );
			var wav:WavFormat = WavFormat.decode( bytes );
			
			try {
				SoundFactory.fromArray( wav.samples, wav.channels, wav.bits, wav.rate, onComplete );
			} catch(e:Error) {
				trace( "il y a erreur sur le sample : "+e.message);
			}
		}

		private function onComplete( sound:Sound ) 
		{
			this.sound = sound;
		}
	}
}