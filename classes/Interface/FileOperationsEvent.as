package Interface
{
	import MPC2000XL_PGM.MPC2000;
	
	import flash.events.Event;
	import flash.filesystem.File;
	
	public class FileOperationsEvent extends Event
	{
		public static const ON_PGM_LOADED:String = "pgmIsLoaded";
		public static const ON_SAMPLES_LOADED:String = "samplesAreLoaded";
		public static const NAME_TOO_LONG:String = "nameTooLong";

		public var program:MPC2000;
		public var samples:Array;
		public var file:File;
		
		public function FileOperationsEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, program:MPC2000=null, samples:Array=null, file:File=null )
		{
			super(type, bubbles, cancelable);
			this.program = program;
			this.samples = samples;
			this.file = file;
		}
		
		public override function clone():Event {
			return new FileOperationsEvent(type, bubbles, cancelable, program, samples, file );
		}
		
		public override function toString():String {
			return '[FileOperationsEvent type="'+ type +'" bubbles=' + bubbles + ' cancelable=' + cancelable + ']';
		}
	}
}