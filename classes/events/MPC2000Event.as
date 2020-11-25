package events
{
	import flash.events.Event;
	import flash.filesystem.File;
	import MPC2000XL_PGM.SampleDatas;
	
	public class MPC2000Event extends Event
	{
		public static const UPDATE:String = "updated";
		public static const ON_SAMPLE_ADDED:String = "onSampleAdded";
		public static const ON_SAMPLE_REMOVED:String = "onSampleRemoved";
		public static const SAMPLE_NAME_HAS_CHANGED:String = "sampleNameHasChanged";
		
		public var newSample:SampleDatas;
		public var sampleNameHasChanged:Boolean;
		
		public function MPC2000Event(type:String, bubbles:Boolean=false, cancelable:Boolean=false, newSample:SampleDatas=null, sampleNameHasChanged:Boolean = false )
		{
			super(type, bubbles, cancelable);
			this.newSample = newSample;
			this.sampleNameHasChanged = sampleNameHasChanged;
		}
		
		public override function clone():Event {
			return new MPC2000Event(type, bubbles, cancelable, newSample, sampleNameHasChanged );
		}
		
		public override function toString():String {
			return '[MPC2000Event type="'+ type +'" bubbles=' + bubbles + ' cancelable=' + cancelable + ']';
		}
	}
}