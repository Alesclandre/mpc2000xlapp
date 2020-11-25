package
{
	import air.update.ApplicationUpdaterUI;
	import air.update.events.DownloadErrorEvent;
	import air.update.events.StatusUpdateErrorEvent;
	import air.update.events.StatusUpdateEvent;
	import air.update.events.UpdateEvent;
	
	import com.carlcalderon.arthropod.Debug;
	
	import flash.desktop.NativeApplication;
	import flash.events.ErrorEvent;
	import flash.events.EventDispatcher;

	public class AppUpdater extends EventDispatcher
	{
		private var appUpdater:ApplicationUpdaterUI = new ApplicationUpdaterUI();
		private var _version:String;
		
		public function AppUpdater()
		{
			checkForUpdate();
		}
		

		public function checkForUpdate():void {
			setApplicationVersion(); // Find the current version so we can show it below
			appUpdater.updateURL = "http://www.mpc2000xlapp.com/downloads/update_new.xml"; // Server-side XML file describing update
			//appUpdater.configurationFile = new File("app:/update.xml");
			appUpdater.isCheckForUpdateVisible = false; // We won't ask permission to check for an update
			appUpdater.addEventListener(UpdateEvent.INITIALIZED, onUpdate); // Once initialized, run onUpdate
			appUpdater.addEventListener(ErrorEvent.ERROR, onError); // If something goes wrong, run onError
			appUpdater.addEventListener(DownloadErrorEvent.DOWNLOAD_ERROR, onError); // If something goes wrong, run onError
			appUpdater.addEventListener(StatusUpdateErrorEvent.UPDATE_ERROR, onError); // If something goes wrong, run onError
			appUpdater.addEventListener(StatusUpdateEvent.UPDATE_STATUS, seeStatus); // Recu après avoir chargé les status, et après CheckNow
			appUpdater.initialize(); // Initialize the update framework
		}
		
		private function seeStatus(e:StatusUpdateEvent):void {			
			Debug.log( "status are updated" );
			Debug.log( "status = "+e );
			trace("status = "+e);
			dispatchEvent( e );
		}
		
		private function onError(event:ErrorEvent):void {
			trace( event );
			Debug.log( event );	
		}
		
		private function onUpdate(event:UpdateEvent):void {
			Debug.log( "the application is checking for updates");
			appUpdater.checkNow(); // Go check for an update now
		}
		
		// Find the current version for our Label below
		private function setApplicationVersion():void {
			var appXML:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = appXML.namespace();
			trace( "Current version is " + appXML.ns::versionNumber );
			_version = appXML.ns::versionNumber;
		}
		
		public function get version():String {
			return _version;
		}
	}
}