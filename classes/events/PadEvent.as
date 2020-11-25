package events
{
	import flash.events.Event;
	
	public class PadEvent extends Event
	{
		public static const UPDATE:String = "updatePad";
		public static const REMOVE_NOTE:String = "removeNote";
		public static const PLAYED:String = "played";
		public var padId:int;
		public var files:Array;
		
		public function PadEvent(type:String, padId:int=-1, files:Array=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.padId = padId;
			this.files = files;
		}
		
		public override function clone():Event {
			return new PadEvent(type, padId, files, bubbles, cancelable );
		}
		
		public override function toString():String {
			return '[PadEvent type="'+ type +'" padId=' + padId + '" files=' + files + '" bubbles=' + bubbles + ' cancelable=' + cancelable + ']';
		}
	}
}