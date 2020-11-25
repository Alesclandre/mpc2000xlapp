package events
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.filesystem.File;
	
	public class MPC2000ErrorEvent extends ErrorEvent
	{
		public static const NOT_A_VALID_SOUND:String = "notAValidSound";
		
		public var sampleName:String;
		
		public function MPC2000ErrorEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, text:String="", id:int=0, sampleName:String="" )
		{
			super(type, bubbles, cancelable, text, id);
			this.sampleName = sampleName;
		}
		
		public override function clone():Event {
			return new MPC2000ErrorEvent(type, bubbles, cancelable, text, errorID, sampleName );
		}
		
		public override function toString():String {
			return '[MPC2000ErrorEvent type="'+ type +'" bubbles=' + bubbles + ' cancelable=' + cancelable + ']';
		}
	}
}