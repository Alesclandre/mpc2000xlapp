package events
{
	import MPC2000XL_PGM.SampleDatas;
	
	import flash.events.Event;
	
	public class SoundsListingEvent extends Event
	{
		public static const UPDATE:String = "updateSampleList";
		public static const ADD_SAMPLES:String = "addSamples";
		public static const REMOVE_SAMPLE:String = "removeSample";
		public static const PLAY_SAMPLE:String = "playSample";
		public static const CHANGE_SAMPLE_NAME:String = "changeSampleName";
		public static const NEXT_SAMPLE:String = "nextSample";
		public static const DRAGGED:String = "dragged";
		public static const DRAG_STOPPED:String = "dragStopped";
		
		public var sample:SampleDatas;
		public var sampleFiles:Array;
		public var newName:String;
		
		public function SoundsListingEvent(type:String, sample:SampleDatas=null, sampleFiles:Array=null, newName:String="", bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.sample = sample;
			this.sampleFiles = sampleFiles;
			this.newName = newName;
		}
		
		public override function clone():Event {
			return new SoundsListingEvent(type, sample, sampleFiles, newName, bubbles, cancelable );
		}
		
		public override function toString():String {
			return '[SoundsListingEvent type="'+ type +'" sampleName=' + sample.name + '" sampleFiles=' + sampleFiles + '" bubbles=' + bubbles + ' cancelable=' + cancelable + ']';
		}
	}
}