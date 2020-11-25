package Interface.Graphics.SampleList
{
	import UI.MouseCursors;
	
	import events.SoundsListingEvent;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import gs.TweenLite;
	
	public class BackgroundSampleClip extends Sprite
	{
		var rectangle:Sprite = new Sprite();
		var isPressed:Boolean = false;
		
		var parentSample:SampleClip;
		
		public function BackgroundSampleClip()
		{
			super();
			
			traceRectangle();
			rectangle.alpha = 0;
			addChild( rectangle );
			
			enable();
			addEventListener( MouseEvent.MOUSE_DOWN, onPress );
			addEventListener( MouseEvent.RELEASE_OUTSIDE, onUp );
			addEventListener( MouseEvent.MOUSE_UP, onUp );
			
			addEventListener( Event.ADDED_TO_STAGE, onAdded );
		}
		
		public function enable() {
			addEventListener( MouseEvent.ROLL_OVER, onOver );
			addEventListener( MouseEvent.ROLL_OUT, onOut );
		}
		
		public function disable() {
			removeEventListener( MouseEvent.ROLL_OVER, onOver );
			removeEventListener( MouseEvent.ROLL_OUT, onOut );
		}

		private function onAdded(e:Event):void {
			parentSample = SampleClip( this.parent );
			removeEventListener( Event.ADDED_TO_STAGE, onAdded );
		}

		private function onOver(event:MouseEvent):void
		{
			Mouse.cursor = MouseCursors.HAND;
			TweenLite.to( rectangle, .3, {alpha:1} );
		}
		
		private function onOut(event:MouseEvent):void
		{
			Mouse.cursor = MouseCursor.AUTO;
			TweenLite.to( rectangle, .3, {alpha:0} );
		}
		
		private function onPress(event:MouseEvent):void
		{
			isPressed = true;
			removeEventListener( MouseEvent.ROLL_OUT, onOut );
			
			dispatchEvent( new SoundsListingEvent( SoundsListingEvent.DRAGGED, parentSample.sample ) );
		}
		
		private function onUp(event:MouseEvent):void
		{
			isPressed = false;
			Mouse.cursor = MouseCursor.AUTO;
			onOut(null);
			addEventListener( MouseEvent.ROLL_OUT, onOut );
			
			dispatchEvent( new SoundsListingEvent( SoundsListingEvent.DRAG_STOPPED, parentSample.sample ) );
		}
		
		private function traceRectangle() {
			rectangle.graphics.beginFill( 0xA2AD4A );
			rectangle.graphics.drawRect(0, 0, 303, 32);
			rectangle.graphics.endFill();
		}
	}
}