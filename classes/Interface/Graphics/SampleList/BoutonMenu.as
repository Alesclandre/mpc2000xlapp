package Interface.Graphics.SampleList
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import gs.TweenLite;
	import gs.plugins.TintPlugin;
	import gs.plugins.TweenPlugin;
	
	public class BoutonMenu extends MovieClip
	{
		public function BoutonMenu()
		{
			super();	
			
			TweenPlugin.activate([TintPlugin]);
			addEventListener( MouseEvent.ROLL_OVER, onOver );
			addEventListener( MouseEvent.ROLL_OUT, onOut );
		}
		
		private function onOver(e:MouseEvent):void {
			TweenLite.to( this, .3, {tint:0xFFFFFF});
		}
		
		private function onOut(e:MouseEvent):void {			
			TweenLite.to( this, .2, {removeTint:true });
		}
	}
}