package UI
{
	import Interface.Graphics.Messages.MessageBox;
	
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.MouseEvent;

	public class Windows
	{
		public static var window : NativeWindow;
		
		public function Windows()
		{
		}
		
		public static function showErrorWindow( message:String ):void {
			var options:NativeWindowInitOptions = new NativeWindowInitOptions(); 
			options.maximizable = false;
			options.resizable = false;
			options.systemChrome = NativeWindowSystemChrome.STANDARD; 
			options.type = NativeWindowType.UTILITY;
			
			var messageBox:MessageBox = new MessageBox( message );
			messageBox.ok_mc.addEventListener(MouseEvent.CLICK, closeErrorWindow );
			messageBox.x = -messageBox.fond_mc.x;
			messageBox.y = -messageBox.fond_mc.y;
			
			window = new NativeWindow(options); 
			window.x = 300; 
			window.y = 200; 
			window.stage.scaleMode = StageScaleMode.NO_SCALE; 
			window.stage.align = StageAlign.TOP_LEFT; 
			window.stage.stageWidth = messageBox.width; 
			window.stage.stageHeight = messageBox.height; 
			window.stage.addChild(messageBox); 
			window.alwaysInFront = true; 
			window.visible = true;
			window.activate();
		}
		
		public static function closeErrorWindow(e:MouseEvent):void {
			window.close();
		}
	}
}