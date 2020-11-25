package Interface.Graphics.Pads
{
	
	import Interface.Graphics.MPC2000XL;
	import MPC2000XL_PGM.NoteDatas;
	import MPC2000XL_PGM.Pad;
	import events.PadEvent;
	import media.SoundGenerator;
	import media.WaveSound;
	
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.net.FileReference;
	import flash.text.TextField;
	
	import gs.TweenLite;
	import gs.plugins.GlowFilterPlugin;
	import gs.plugins.TintPlugin;
	import gs.plugins.TweenPlugin;

	public class InteractivePad extends MovieClip
	{
		public var son_txt:TextField;
		public var note_txt:TextField;
		public var fond_mc:MovieClip;
		public var noSound_mc:MovieClip;
		public var onClic:Function;
		public var sampleName:String;
		public var remove_btn:SimpleButton;
		public var removeSampleCallback:Function;
		public var numeroNote:int;
		
		private var _sound:SoundGenerator;
		private var _padID:int;
		
		public function InteractivePad()
		{
			super();
			
			noSound_mc.visible = false;
			remove_btn.visible = false;
			TweenPlugin.activate([TintPlugin, GlowFilterPlugin]);
			
			note_txt.mouseEnabled = false;
			son_txt.mouseEnabled = false;
			noSound_mc.mouseEnabled = false;
			
			fond_mc.addEventListener( MouseEvent.ROLL_OVER, onOver );
			fond_mc.addEventListener( MouseEvent.ROLL_OUT, onOut );
			fond_mc.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			fond_mc.addEventListener( MouseEvent.MOUSE_UP, onMouseup );
			remove_btn.addEventListener(MouseEvent.CLICK, onRemoveHandler );
		}

		private function onRemoveHandler(e:MouseEvent):void {
			trace("onRemoveHandler : pad "+_padID+"  numeroNote :"+numeroNote +"  noet_txt: "+note_txt.text);
			if( removeSampleCallback != null ) removeSampleCallback( this.padID );
			update( numeroNote );
			dispatchEvent( new PadEvent( PadEvent.REMOVE_NOTE, _padID,null,true ) );
		}
		
		public function disableSound() {
			fond_mc.removeEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			noSound_mc.visible = true;
		}
		
		public function enableSound() {
			fond_mc.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			noSound_mc.visible = false;			
		}
		
		public function update( numeroNote:Number, sampleName:String="", sound:SoundGenerator=null, onClic:Function=null ) {
			this.sound = sound;
			this.sampleName = sampleName;
			this.son_txt.text = sampleName;
			if( sampleName == "" ) remove_btn.visible = false;
			else remove_btn.visible = true;
			this.note_txt.text = "Note : "+numeroNote;
			this.numeroNote = numeroNote;
			this.onClic = onClic;
		}

		private function onMouseup(event:MouseEvent):void
		{
			var c:ColorTransform = new ColorTransform();
			c.color = 0xFFFFFF;
			fond_mc.transform.colorTransform = c;
		}

		private function onMouseDown(event:MouseEvent):void
		{
			var c:ColorTransform = new ColorTransform();
			c.color = 0x999999;
			fond_mc.transform.colorTransform = c;
			
			if( onClic != null ) onClic( sampleName );
			dispatchEvent( new PadEvent( PadEvent.PLAYED, padID ) );
		}
		
		public function playSound():void {
			if( onClic != null ) onClic( sampleName );
			TweenLite.to( fond_mc, .01, {glowFilter:{color:0xffffff, alpha:.8, blurX:16, blurY:16}, tint:0xFFFFFF, onComplete:onOut});
		}

		private function onOver(e:MouseEvent):void {
			TweenLite.to( fond_mc, .3, {glowFilter:{color:0xffffff, alpha:.8, blurX:16, blurY:16}, tint:0xFFFFFF});
		}

		private function onOut(e:MouseEvent=null):void {			
			TweenLite.to( fond_mc, .2, {glowFilter:{color:0xffffff, alpha:0, blurX:0, blurY:0, remove:true }, removeTint:true });
		}
		
		public function get padID():int {
			return _padID;
		}
		
		public function set padID(value:int):void {
			_padID = value;
		}
		
		public function get sound():SoundGenerator
		{
			return _sound;
		}
		
		public function set sound(value:SoundGenerator):void
		{
			_sound = value;
		}

	}
}