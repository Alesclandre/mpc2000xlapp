package Interface.Graphics.SampleList
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	import gs.TweenLite;
	import gs.easing.Strong;
	
	import org.moonpalace.MaTrace;
	import org.moonpalace.utils.MathExt;
	
	public class LiftClip extends Sprite
	{
		private const ESPACEMENT:uint = 5;
		private const MIN_HEIGHT:uint = 10;
		private var MAX_HEIGHT:Number;
		
		public var topArrow:MovieClip = new MovieClip();
		public var bottomArrow:MovieClip = new MovieClip();
		public var backLift:MovieClip = new MovieClip();
		public var lift:MovieClip = new MovieClip();
		
		private var minYLift:Number;
		private var maxYLift:Number;
		private var maxYClip:Number;
		private var minYClip:Number;
		private var incrementY:Number;
		
		private var mousePosY:Number;
		private var clip:DisplayObject;
		private var timerDepart:Timer = new Timer( 500, 1);
		private var increment:Number;
		
		public function LiftClip() 
		{
			y = int( y );
			x = int( x );
			
			topArrow.buttonMode = bottomArrow.buttonMode = lift.buttonMode = true;
			topArrow.mouseChildren = bottomArrow.mouseChildren = false;
		}
		
		public function init( clipToLift:DisplayObject, increment:Number = 20 ) 
		{
			trace( "LiftClip init" );
			clip = clipToLift;
			this.increment = increment;
			//if( clip.mask == null ) throw new Error( "Class LiftClip : You must add a mask to the clip lifted in order to lift this clip !" );			
			
			var clipMaskHeight:Number = (clip.mask) ? clip.mask.height : height;
			/*if ( clip.height <= clipMaskHeight ) visible = false;
			else visible = true;*/
			
			var arrowHeight:Number = 18;
			
			backLift.useHandCursor = false;
			backLift.height = clipMaskHeight - 2 * arrowHeight;
			bottomArrow.y = backLift.y + backLift.height + arrowHeight; //Ne pas oublier que la bottomArrow est renversée !!
			
			MAX_HEIGHT = backLift.height - 2*ESPACEMENT;

			update();
			clip.y = maxYClip;
			lift.y = minYLift;
			
			lift.addEventListener( MouseEvent.MOUSE_DOWN , liftPressHandler );
			backLift.addEventListener( MouseEvent.CLICK , onBackClick );
			clip.addEventListener( MouseEvent.MOUSE_WHEEL, onMouseWheel );
			
			topArrow.addEventListener( MouseEvent.MOUSE_DOWN , previous );
			bottomArrow.addEventListener( MouseEvent.MOUSE_DOWN , next );
			
			stage.addEventListener( KeyboardEvent.KEY_DOWN, keyboardHandler );
			stage.addEventListener( KeyboardEvent.KEY_UP, stopTimerEvents );
		}

		private function stopTimerEvents(event:KeyboardEvent=null):void
		{
			timerDepart.reset();
			removeEventListener( Event.ENTER_FRAME, previous );
			removeEventListener( Event.ENTER_FRAME, next );
			timerDepart.removeEventListener( TimerEvent.TIMER, previousContinue );
			timerDepart.removeEventListener( TimerEvent.TIMER, nextContinue );
			stage.removeEventListener( MouseEvent.MOUSE_UP , stopScroll );
		}

		private function keyboardHandler(e:KeyboardEvent):void {
			if( e.keyCode == Keyboard.DOWN ) next();
			else if( e.keyCode == Keyboard.UP ) previous();
		}
		
		public function update():void {	
			var amplitudeClip:Number = int( (clip.height - clip.mask.height) / increment ) * increment + increment;
			
			if( clip.height < clip.mask.height ) lift.height = MAX_HEIGHT;
			else lift.height = Math.max( 20, MAX_HEIGHT - 5 * amplitudeClip / increment );
			
			minYLift = int( backLift.y + ESPACEMENT );
			maxYLift = int( backLift.y + backLift.height - lift.height - ESPACEMENT );
			if( lift.y > maxYLift ) lift.y = maxYLift;
			
			maxYClip = /*clip.y =*/ y;
			minYClip = maxYClip - amplitudeClip;
			
			setClipPosition();
		}
		
		private function onMouseWheel(e:MouseEvent):void 
		{
			if ( e.delta > 0 ) descends();
			else if (e.delta < 0 ) monte();
		}
		
		private function stopScroll(e:MouseEvent):void 
		{
			stopTimerEvents();
		}
		
		private function descends() {
			if ( clip.y < maxYClip ) {
				//clip.y += Math.min( increment, Math.abs( clip.y - maxYClip) );
				var posY:Number = clip.y + Math.min( increment, Math.abs( clip.y - maxYClip) );
				TweenLite.to( clip, .3, {y:posY, ease:Strong.easeOut } );
			}
			setLiftPosition();
		}
		
		private function previous(e:Event=null):void 
		{
			descends();
			
			timerDepart.reset();
			timerDepart.addEventListener( TimerEvent.TIMER, previousContinue );
			timerDepart.start();
			stage.addEventListener( MouseEvent.MOUSE_UP , stopScroll );
		}
		
		private function previousContinue(e:TimerEvent):void 
		{
			addEventListener( Event.ENTER_FRAME, previous );
		}
		
		private function monte() {
			if ( clip.y > minYClip ) {
				//clip.y -= Math.min( increment, Math.abs( clip.y - minYClip) );
				var posY:Number = clip.y - Math.min( increment, Math.abs( clip.y - minYClip) );
				TweenLite.to( clip, .3, {y:posY, ease:Strong.easeOut } );
			}
			setLiftPosition();
		}
		
		private function next(e:Event=null):void 
		{
			monte();
			
			timerDepart.reset();
			timerDepart.addEventListener( TimerEvent.TIMER, nextContinue );
			timerDepart.start();
			stage.addEventListener( MouseEvent.MOUSE_UP , stopScroll );
		}
		
		private function nextContinue(e:TimerEvent):void 
		{
			addEventListener( Event.ENTER_FRAME, next );
		}
		
		private function onBackClick(e:MouseEvent):void 
		{
			lift.y = Math.min( mouseY, maxYLift );
			setClipPosition();
			//setLiftPosition();
		}
		
		private function liftPressHandler(e:MouseEvent):void 
		{
			mousePosY = mouseY - lift.y;
			stage.addEventListener( MouseEvent.MOUSE_UP , onMouseUp );
			stage.addEventListener( MouseEvent.MOUSE_MOVE , trackPosition );
		}
		
		private function trackPosition(e:MouseEvent):void 
		{		
			var posY:Number = mouseY - mousePosY;
			lift.y = Math.min( Math.max( minYLift, mouseY - mousePosY ), maxYLift) ;
			
			setClipPosition();
		}
		
		private function setClipPosition() {
			//clip.y = MathExt.map( lift.y, minYLift, maxYLift, maxYClip, minYClip );
			TweenLite.to( clip, .3, {y:MathExt.map( lift.y, minYLift, maxYLift, maxYClip, minYClip ), ease:Strong.easeOut } );
		}
		
		private function setLiftPosition() {
			//lift.y = MathExt.map( clip.y, maxYClip, minYClip, minYLift, maxYLift);
			TweenLite.to( lift, .3, {y:MathExt.map( clip.y, maxYClip, minYClip, minYLift, maxYLift), ease:Strong.easeOut } );
		}
		
		private function onMouseUp(e:MouseEvent):void 
		{
			setLiftPosition();
			stage.removeEventListener( MouseEvent.MOUSE_UP , onMouseUp );
			stage.removeEventListener( MouseEvent.MOUSE_MOVE , trackPosition );
		}
		
	}
	
}