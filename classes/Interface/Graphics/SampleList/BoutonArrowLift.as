package Interface.Graphics.SampleList
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.moonpalace.utils.TimelineHandler;
	
	public class BoutonArrowLift extends MovieClip
	{
		public function BoutonArrowLift()
		{
			super();
			stop();
			
			addEventListener( MouseEvent.ROLL_OVER, onOver );
			addEventListener( MouseEvent.ROLL_OUT, onOut );
		}
		
		private function onOver(e:MouseEvent):void {
			play();
		}
		
		private function onOut(e:MouseEvent):void {	
			addEventListener( Event.ENTER_FRAME, rewind );
		}
		
		private function rewind( pEvt:Event ) {
			pEvt.currentTarget.gotoAndStop( pEvt.currentTarget.currentFrame - 2 );
			if( pEvt.currentTarget.currentFrame <= 2 ) {
				pEvt.currentTarget.gotoAndStop( 1 );
				pEvt.currentTarget.removeEventListener( Event.ENTER_FRAME , rewind );	
			}
		}
	}
}