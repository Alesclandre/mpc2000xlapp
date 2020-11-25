package media
{
	import events.WaveSoundEvent;
	import media.PCMFormat;
	import media.SNDFormat;
	
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SampleDataEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	public class SoundGenerator extends EventDispatcher {
		
		/*
		* *********************************************************
		* CLASS PROPERTIES
		* *********************************************************
		*
		*/
		private var byteStream:FileStream;
		private var sndHeader:ByteArray;
		private var waveData:ByteArray;
		private var sndFormat:ISoundFormat;
		private var sound:Sound;
		private var isLoadStarted:Boolean = false;
		private var isLoaded:Boolean = false;
		private var extension:String;
		private var __bytesLoaded:uint = 0;
		private var __bytesTotal:uint = 0;
		private var __length:Number = 0;
		private var __url:String;
		
		/*
		* *********************************************************
		* CONSTRUCTOR
		* *********************************************************
		*
		*/
		/**
		 * Creates a new WaveSound object. If you pass a valid URLRequest object to the WaveSound constructor,
		 * the constructor automatically calls the load() function for the Sound object.
		 * If you do not pass a valid URLRequest object to the WaveSound constructor,
		 * you must call the load() function for the WaveSound object yourself, or the stream will not load. 
		 * 
		 * Once load() is called on a WaveSound object, you can't later load a different sound file into that WaveSound object.
		 * To load a different sound file, create a new WaveSound object.
		 * 
		 * @param stream:URLRequest (default = null) — The URL that points to an external WAV file. 
		 */
		public function SoundGenerator( filePath:String=null ) {
			var file:File = new File( filePath );
			super();
			extension = filePath.slice(-3).toLowerCase();
			trace( extension );
			if( extension != "wav" && extension != "snd" ) throw new Error( "The format is not good. Should be wav or snd" );
			
			/*byteStream = new URLStream();
			byteStream.endian = Endian.LITTLE_ENDIAN;
			byteStream.addEventListener(Event.COMPLETE,completeHandler);
			byteStream.addEventListener(HTTPStatusEvent.HTTP_STATUS,httpStatusHandler);
			byteStream.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
			byteStream.addEventListener(ProgressEvent.PROGRESS,progressHandler);*/
			byteStream = new FileStream();
			byteStream.endian = Endian.LITTLE_ENDIAN;
			
			if (file != null) {
				load(file);
			}
			completeHandler(null);
		}
		
		/*
		* *********************************************************
		* PRIVATE METHODS
		* *********************************************************
		*
		*/
		private function completeHandler(event:Event):void {
			sndHeader = new ByteArray();
			sndHeader.endian = Endian.LITTLE_ENDIAN;
			
			//var sndClass:Class = (extension == "wav") ? Class( ApplicationDomain.currentDomain.getDefinition( "media.PCMFormat" ) ) : Class( ApplicationDomain.currentDomain.getDefinition( "media.SNDFormat" ) );
			//sndFormat = new sndClass();
			sndFormat = (extension == "wav") ? new PCMFormat() : new SNDFormat();
			byteStream.readBytes(sndHeader,0,  sndFormat.getHeaderSize());
			
			try {
				sndFormat.analyzeHeader(sndHeader);
			} catch (e:Error) {
				trace(e);
				dispatchEvent(new WaveSoundEvent(WaveSoundEvent.DECODE_ERROR));
				return;
			}
			
			waveData = new ByteArray();
			waveData.endian = Endian.LITTLE_ENDIAN;
			var bytesToRead:uint = (sndFormat is PCMFormat ) ? Math.min( byteStream.bytesAvailable, PCMFormat( sndFormat ).waveDataLength) : byteStream.bytesAvailable; //byteStream.bytesAvailable < waveFormat.waveDataLength ? byteStream.bytesAvailable : waveFormat.waveDataLength;
			byteStream.readBytes(waveData,0,bytesToRead);
			
			byteStream.close();
			
			var swf:SWFFormat = new SWFFormat(sndFormat);
			var compiledSWF:ByteArray = swf.compileSWF(waveData);
			var loader:Loader = new Loader();
			var loaderContext:LoaderContext = new LoaderContext();
			loaderContext.allowCodeImport = true;
			loader.loadBytes(compiledSWF, loaderContext);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,generateCompleteHandler);
			
		}
		
		private function httpStatusHandler(event:HTTPStatusEvent):void {
			dispatchEvent(event);	
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void {
			dispatchEvent(event);
		}
		
		private function progressHandler(event:ProgressEvent):void {
			__bytesLoaded = event.bytesLoaded;
			__bytesTotal = event.bytesTotal;
			dispatchEvent(event);
		}
		
		private function openHandler(event:Event):void {
			dispatchEvent(event);
		}
		
		private function securityErrorHandler(event:SecurityErrorEvent):void {
			dispatchEvent(event);
		}
		
		private function generateCompleteHandler(event:Event):void {
			var soundClass:Class = LoaderInfo(event.target).applicationDomain.getDefinition(SWFFormat.CLASS_NAME) as Class;
			sound = new soundClass() as Sound;
			__length = sound.length;
			isLoaded = true;
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/*
		* *********************************************************
		* PUBLIC METHODS
		* *********************************************************
		*
		*/
		/**
		 * Initiates loading of an external WAV file from the specified URL. 
		 * 
		 * @param request:URLRequest — A URLRequest object specifying the URL to download. If the value of this parameter or the URLRequest.url property of the URLRequest object passed are null, Flash Player throws a null pointer error.  
		 * 
		 * @event complete:Event — Dispatched after data has loaded successfully.
		 * @event httpStatus:HTTPStatusEvent — If access is by HTTP, and the current Flash Player environment supports obtaining status codes, you may receive these events in addition to any complete or error event.
		 * @event ioError:IOErrorEvent — The load operation could not be completed.
		 * @event open:Event — Dispatched when a load operation starts.
		 * @event securityError:SecurityErrorEvent — A load operation attempted to retrieve data from a server outside the caller's security sandbox. This may be worked around using a policy file on the server. 
		 * @event decodeError:WAVPlayerEvent — Dispatched when a decode operation could not be completed. (i.e. incorrect PCM format).
		 */
		public function load( file:File ):void {
			if (isLoadStarted) {
				return;
			}
			
			isLoadStarted = true;
			isLoaded = false;
			byteStream.open( file, FileMode.READ );
			trace( "byteStream opened" );
		}
		
		/**
		 * Closes the stream, causing any download of data to cease. No data may be read from the stream after the close() method is called. 
		 */
		public function close():void {
			byteStream.close();
			__bytesLoaded = 0;
			__bytesTotal = 0;
			__url = null;
			__length = 0;
			isLoaded = false;
		}
		
		/**
		 * Generates a new SoundChannel object to play back the sound. This method returns a SoundChannel object, which you access
		 * to stop the sound and to monitor volume. (To control the volume, panning, and balance, access the SoundTransform object
		 * assigned to the sound channel.). Returns null if sound was not loaded.
		 * 
		 * @param startTime:Number (default = 0) — The initial position in milliseconds at which playback should start.
		 * @param loops:int (default = 0) — Defines the number of times a sound loops before the sound channel stops playback. 
		 * @param sndTransform:SoundTransform (default = null) — The initial SoundTransform object assigned to the sound channel.  
		 */
		public function play(startTime:Number = 0, loops:uint = 0, sndTransform:SoundTransform = null):SoundChannel {
			if (isLoaded) {
				return sound.play(startTime, loops, sndTransform);
			}
			
			return null;
		}
		
		/*
		* *********************************************************
		* SETTERS/GETTERS
		* *********************************************************
		*
		*/
		/**
		 * Returns the currently available number of bytes in this sound object. read-only.
		 */
		public function get bytesLoaded():uint {
			return __bytesLoaded;
		}
		
		/**
		 * Returns the total number of bytes in this sound object. read-only.
		 */
		public function get bytesTotal():uint {
			return __bytesTotal;
		}
		
		/**
		 * The length of the current sound in milliseconds. read-only.
		 */
		public function get length():Number {
			return __length;	
		}
		
		/**
		 * The URL from which this sound was loaded. read-only.
		 */
		public function get url():String {
			return __url;
		}
		
		/**
		 * Returns a copy of audio data (from PCM wave-data) in ByteArray. Returns null if sound was not loaded. read-only.
		 */
		public function get audioData():ByteArray {
			if (isLoaded) {
				var outData:ByteArray = new ByteArray();
				outData.endian = Endian.LITTLE_ENDIAN;
				outData.writeBytes(waveData);
				return outData;
			}
			
			return null;
		}
		
		/**
		 * Returns a copy of PCMFormat object, which contains some parameters of loaded sound. Returns null if sound was not loaded. read-only.
		 */
		public function get audioFormat():PCMFormat {
			if (isLoaded) {
				var format:PCMFormat = new PCMFormat();
				format.analyzeHeader(sndHeader);
				return format;
			}
			
			return null;
		}
	}
}
import media.ISoundFormat;
import media.PCMFormat;
import media.SNDFormat;

import flash.utils.ByteArray;
import flash.utils.Endian;

internal class SWFFormat {
	
	/*
	* *********************************************************
	* CLASS PROPERTIES
	* *********************************************************
	*
	*/
	private static const SWF_PART0:String = '46575309';
	private static const SWF_PART1:String = '7800055F00000FA000000C01004411080000004302FFFFFFBF150B00000001005363656E6520310000BF14C7000000010000000010002E00000000080013574156506C61796572536F756E64436C6173730B666C6173682E6D6564696105536F756E64064F626A6563740C666C6173682E6576656E74730F4576656E744469737061746368657205160116031802160600050701020702040701050704070300000000000000000000000000010102080300010000000102010104010003000101050603D030470000010101060706D030D04900470000020201010517D0306500600330600430600230600258001D1D1D6801470000BF03';
	private static const SWF_PART2:String = '3F131800000001000100574156506C61796572536F756E64436C61737300440B0800000040000000';
	
	public static const CLASS_NAME:String = 'WAVPlayerSoundClass';
	
	private var sndFormat:ISoundFormat;
	
	/*
	* *********************************************************
	* CONSTRUCTOR
	* *********************************************************
	*
	*/
	public function SWFFormat(format:ISoundFormat) {
		sndFormat = format;
	}
	
	/*
	* *********************************************************
	* PRIVATE METHODS
	* *********************************************************
	*
	*/
	private function writeBytesFromString(byteArray:ByteArray,bytesHexString:String):void {
		var length:uint = bytesHexString.length;
		
		for (var i:uint = 0;i<length;i+=2) {
			var hexByte:String = bytesHexString.substr(i,2);
			var byte:uint = Number('0x'+hexByte);
			byteArray.writeByte(byte);
		}
	}
	
	private function traceArray(array:ByteArray):String { // for debug
		var out:String = '';
		var pos:uint = array.position;
		array.position = 0;
		
		while (array.bytesAvailable) {
			var str:String = array.readUnsignedByte().toString(16).toUpperCase();
			str = str.length < 2 ? '0'+str : str;
			out += str+' ';
		}
		
		array.position = pos;
		return out;
	}
	
	private function getFormatByte():uint {
		//var byte:uint = (pcmFormat.bitsPerSample == 0x10) ? 0x32 : 0x00;
		var byte:uint = 0x32;
		byte += (sndFormat.channels-1);
		byte += 4*(Math.floor(sndFormat.sampleRate/5512.5).toString(2).length-1); // :-)
		return byte;
	}
	
	/*
	* *********************************************************
	* PUBLIC METHODS
	* *********************************************************
	*
	*/
	public function compileSWF(audioData:ByteArray):ByteArray {
		var dataLength:uint = audioData.length;
		var swfSize:uint = dataLength+307;
		var totalSamples:uint = dataLength/sndFormat.blockAlign;
		var output:ByteArray = new ByteArray();
		output.endian = Endian.LITTLE_ENDIAN;
		writeBytesFromString(output,SWFFormat.SWF_PART0);
		output.writeUnsignedInt(swfSize);
		writeBytesFromString(output,SWFFormat.SWF_PART1);
		output.writeUnsignedInt(dataLength+7);
		output.writeByte(1);
		output.writeByte(0);
		output.writeByte(getFormatByte());
		output.writeUnsignedInt(totalSamples);
		output.writeBytes(audioData);
		writeBytesFromString(output,SWFFormat.SWF_PART2);
		return output;
	}
}