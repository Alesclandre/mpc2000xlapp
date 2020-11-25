package 
{
	import Interface.Graphics.MPC2000XL;
	import Interface.Graphics.Pads.Pad_Interface;
	import Interface.Menus;
	
	import UI.MouseCursors;
	import UI.PGM_Window;
	
	import air.update.ApplicationUpdaterUI;
	import air.update.events.DownloadErrorEvent;
	import air.update.events.StatusUpdateErrorEvent;
	import air.update.events.StatusUpdateEvent;
	import air.update.events.UpdateEvent;
	
	import com.carlcalderon.arthropod.Debug;
	import com.google.analytics.GATracker;
	import com.google.analytics.debug.DebugConfiguration;
	
	import flash.desktop.NativeApplication;
	import flash.display.MovieClip;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.display.Stage;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.InvokeEvent;
	import flash.events.NetStatusEvent;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.net.SharedObject;
	import flash.net.SharedObjectFlushStatus;
	import flash.ui.Mouse;
	
	//[SWF(frameRate="25", width="744", height="629", backgroundColor="0xFFFFFF")]
	public class Application extends MovieClip
	{
		public static const APP_NAME:String = "2KXL";
		public static var GLOBAL_STAGE:Stage;		
		public static var HOTKEYS:Array;	
		public static var KEYNAMES:Array;	
		public static var sharedObject:SharedObject;
		//Using keycodes
		public static var defaultKeys:Array = [87,88,67,86,
			81,83,68,70,
			65,90,69,82,
			49,50,51,52];
		public static var defaultKeyNames:Array = ["W","X","C","V",
			"Q","S","D","F",
			"A","Z","E","R",
			"&","é","\"","'"];
		
		//public static var menus:Menus;
		private var appUpdater:ApplicationUpdaterUI = new ApplicationUpdaterUI();
		public static var tracker:GATracker;
		
		public function Application()
		{
			super();
			
			Debug.log("2KXL Launched");
			GLOBAL_STAGE = stage;
			
			sharedObject = SharedObject.getLocal( APP_NAME );
			
			HOTKEYS = sharedObject.data.hotkeys;
			if( HOTKEYS == null ) {
				saveSharedObjects( defaultKeys, "hotkeys" );
				HOTKEYS = defaultKeys;
			}
			KEYNAMES = sharedObject.data.keyNames;
			if( KEYNAMES == null ) {
				saveSharedObjects( defaultKeyNames, "keyNames" );
				KEYNAMES = defaultKeyNames;
			}
			
			var appUdater:AppUpdater = new AppUpdater();
			
			//Analytics only on the first launch
			tracker = new GATracker(this, "UA-24102351-1", "AS3", false);
			tracker.trackPageview( "/2KXL_Launched" );
			
			MouseCursors.addNewCursor( MouseCursors.HAND, new Hand() );
			MouseCursors.addNewCursor( MouseCursors.CLOSED_HAND, new ClosedHand() );
			MouseCursors.addNewCursor( MouseCursors.MODIFY, new ModifyCursor(), 0, 15 );
			
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onInvoke);
		}
		
		public static function saveSharedObjects( objectToSave:*, objectName:String ):void {
			sharedObject.data[objectName] = objectToSave;
			
			var flushStatus:String = null;
			try {
				flushStatus = sharedObject.flush(10000);
			} catch (error:Error) {
				trace("Error...Could not write SharedObject to disk\n");
			}
			if (flushStatus != null) {
				switch (flushStatus) {
					case SharedObjectFlushStatus.PENDING:
						trace("Requesting permission to save object...\n");
						sharedObject.addEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
						break;
					case SharedObjectFlushStatus.FLUSHED:
						trace(objectName+" value flushed to disk.\n");
						break;
				}
			}
		}
		
		private static function onFlushStatus(event:NetStatusEvent):void {
			trace("User closed permission dialog...\n");
			switch (event.info.code) {
				case "SharedObject.Flush.Success":
					trace("User granted permission -- value saved.\n");
					break;
				case "SharedObject.Flush.Failed":
					trace("User denied permission -- value not saved.\n");
					break;
			}
			trace("\n");
			
			sharedObject.removeEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
		}
		
		/**
		* Launch a new window when a pgm file is double-clicked
		 * Or an empty window when no file is opened
		*
		**/
		private function onInvoke( e:InvokeEvent ):void 
		{
			Debug.log("Invocation starts with "+e.arguments.length+" arguments");
			if( e.arguments.length == 0 ) {
				if(NativeApplication.nativeApplication.openedWindows.length <= 2) var window:PGM_Window = new PGM_Window();
			} else {
				for( var i:int = 0; i<e.arguments.length ; i++ ) {
					var file:File = e.currentDirectory.resolvePath( e.arguments[i] );
					trace("onInvoke > "+e.arguments+" //// "+file.nativePath);
					Menus.openDocument( file );
				}
			}
		}
	}
}