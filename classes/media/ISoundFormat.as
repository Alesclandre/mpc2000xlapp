package media
{
	import flash.utils.ByteArray;

	public interface ISoundFormat
	{
		function analyzeHeader( byte:ByteArray ):void;
		function getHeaderSize():uint;
		function get channels():uint;		
		function get sampleRate():uint;
		function get byteRate():uint;
		function get blockAlign():uint;
		function get bitsPerSample():uint;
	}
}