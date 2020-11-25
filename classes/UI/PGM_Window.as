package UI
{
	import Interface.Graphics.MPC2000XL;
	import Interface.Menus;
	
	import MPC2000XL_PGM.MPC2000;
	
	import com.carlcalderon.arthropod.Debug;
	
	import events.MPC2000Event;
	
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.NativeWindowBoundsEvent;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	
	public class PGM_Window extends NativeWindow
	{
		private const WINDOW_WIDTH:int = 744;
		private const WINDOW_HEIGHT:int = 629;
		
		private var _pgmDatas:MPC2000;
		private var _progName:String;
		
		public var mpcInterface:MPC2000XL;
		public var originalFile:File;
		public var history:Array = new Array();
		public var hasBeenSaved:Boolean = true;
		public var menus:Menus;
		
		public function PGM_Window( pgmDatas:MPC2000=null, file:File = null )
		{
			Debug.log("PGM Window constructor");
			
			var options:NativeWindowInitOptions = new NativeWindowInitOptions();
			options.maximizable = false;
			options.resizable = false;
			options.systemChrome = NativeWindowSystemChrome.STANDARD; 
			options.type = NativeWindowType.NORMAL;
			
			super(options);
			
			stage.scaleMode = StageScaleMode.NO_SCALE; 
			stage.align = StageAlign.TOP_LEFT; 
			alwaysInFront = false; 
			visible = true;
			
			menus = new Menus( this );
			
			if( NativeApplication.nativeApplication.activeWindow ) {
				x = NativeApplication.nativeApplication.activeWindow.x + 100;
				y = NativeApplication.nativeApplication.activeWindow.y + 20;
			} else {
				x = int( Math.random() * 100 + 100 );
				y = int( Math.random() * 100 + 100 );
			}
			
			stage.stageWidth = WINDOW_WIDTH;//mpcInterface.width; 
			stage.stageHeight = WINDOW_HEIGHT;//mpcInterface.height; 
			
			mpcInterface = new MPC2000XL( this );
			stage.addChild( mpcInterface ); 
			
			init( pgmDatas, file );
			
			//addEventListener( Event.ACTIVATE, onActivated );
			//Si on est sur windows, il faut stopper le processus en fermant la dernière fenêtre
			if( NativeWindow.supportsMenu ) {
				addEventListener( Event.CLOSE, onClose );
			}
		}

		private function onClose(e:Event):void {
			var nbreWindows:int = NativeApplication.nativeApplication.openedWindows.length;
			if (nbreWindows <= 2 ) NativeApplication.nativeApplication.exit();
			/*for (var i:int = 0; i < nbreWindows; i++) {
				var element:NativeWindow = NativeApplication.nativeApplication.openedWindows[i] as NativeWindow;
				if( element is PGM_Window && 
				
			}*/
		}
		
		public function init( pgmDatas:MPC2000=null, file:File=null ) :void
		{			
			if( pgmDatas == null ) {
				_pgmDatas = new MPC2000();
				
				var nbreWindows:int = NativeApplication.nativeApplication.openedWindows.length - 2;
				progName = "No-name-"+nbreWindows;
				title = progName+".PGM *";
			}
			else _pgmDatas = pgmDatas;			
			
			
			mpcInterface.initMPCwithPGM( _pgmDatas );
			_pgmDatas.addEventListener( MPC2000Event.UPDATE, update );					
			
			if( file != null ) {
				title = file.name;
				progName = file.name.slice(0,-4);
				originalFile = file;
			}
			
		}
		
		private function onActivated( e:Event ) {
			Debug.log( "PGM_Window > "+this+" activated" );
			/*var saveEnabled:Boolean = ( originalFile != null ) && !hasBeenSaved;
			menus.enableSaveMenu( saveEnabled );*/
		}
		
		private function update( e:Event ) {
			Debug.log( "PGM_Window > update title" );
			title = progName+".PGM *";
			hasBeenSaved = false;
			
			//var saveEnabled:Boolean = ( originalFile != null ) && !hasBeenSaved;
			//menus.enableSaveMenu( saveEnabled );
		}
		
		public function get pgmDatas():MPC2000 {
			return _pgmDatas;
		}
		
		public override function toString():String {
			return "[PGM_Window title="+title+"]";
		}


		public function get progName():String {
			return _progName;
		}

		public function set progName(value:String):void {
			_pgmDatas.progName = value;
			_progName = value;
		}

	}
}