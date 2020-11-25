package Interface
{
	import Interface.Graphics.MPC2000XL;
	import Interface.Graphics.Messages.ErrorNameBox;
	import Interface.Graphics.Messages.MessageBox;
	
	import MPC2000XL_PGM.GLOBAL;
	import MPC2000XL_PGM.IO_PGM;
	import MPC2000XL_PGM.MPC2000;
	import MPC2000XL_PGM.SampleDatas;
	
	import UI.PGM_Window;
	import UI.PrefWindow;
	import UI.Windows;
	
	import air.update.events.StatusUpdateEvent;
	
	import com.carlcalderon.arthropod.Debug;
	
	import commandPattern.commands.IUndoableCommand;
	import commandPattern.commands.LoadSoundsCommand;
	
	import flash.desktop.NativeApplication;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.FileListEvent;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.FileReferenceList;
	import flash.net.SharedObject;
	import flash.net.SharedObjectFlushStatus;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	import flash.utils.ByteArray;

	public class Menus
	{
		private static const PREFS:String = "Hotkeys...";
		private static const NEW_FILE:String = "New";
		private static const OPEN:String = "Open...";
		private static const OPEN_RECENT:String = "Open Recent";
		private static const CLOSE:String = "Close";
		private static const QUIT:String = "Quit";
		private static const SAVE:String = "Save";
		private static const SAVE_AS:String = "Save As";
		private static const PGM_ONLY:String = "PGM Only";
		private static const WITH_SOUNDS:String = "With sounds";
		private static const LOAD_SOUNDS:String = "Load Sounds...";
		private static const CHECK_UPDATE:String = "Check for updates...";
		private static const HELP:String = "Help";
		private static const BUG:String = "Bug report";
		private static const DONATE:String = "Donate";
		public static const MAX_RECENT_DOCUMENTS:int = 10;
		
		public static var recentDocuments:Array = new Array(); 
		//private var application:Application;		
		private var pgmWindow:PGM_Window;		
		private var fileOP:FileOperations;
		private var errorBox:ErrorNameBox;
		private var fileToSave:File;
		private var fileList:FileReferenceList;
		private var window:NativeWindow;
		private var saveWithSounds:Boolean = false;
		private var appUpdater:AppUpdater;
		
		public function Menus( pgmWindow:PGM_Window )
		{
			//this.application = application;
			this.pgmWindow = pgmWindow;
			
			var pathRecentDocuments:Array = Application.sharedObject.data.pathRecentDocuments;
			if( pathRecentDocuments != null ) {
				for (var i:int = 0; i < pathRecentDocuments.length; i++) {
					recentDocuments[i] = new File( pathRecentDocuments[i] );
				}
			}
			
			var firstMenu:NativeMenuItem; 
			var fileMenu:NativeMenuItem; 
			var editMenu:NativeMenuItem; 
			var soundsMenu:NativeMenuItem;
			var helpMenu:NativeMenuItem;
			var prefsCommand:NativeMenuItem;
			
			if (NativeWindow.supportsMenu){ 
				this.pgmWindow.menu = new NativeMenu(); 
				this.pgmWindow.menu.addEventListener(Event.SELECT, selectCommandMenu); 
				
				firstMenu = this.pgmWindow.menu.addItem(new NativeMenuItem("Edit")); 
				firstMenu.submenu = new NativeMenu();
				prefsCommand = firstMenu.submenu.addItem( new NativeMenuItem( PREFS ) );
				prefsCommand.addEventListener(Event.SELECT, selectCommand);
				
				fileMenu = this.pgmWindow.menu.addItem(new NativeMenuItem("File")); 
				fileMenu.submenu = createFileMenu(); 
				
				soundsMenu = this.pgmWindow.menu.addItem(new NativeMenuItem("Sounds")); 
				soundsMenu.submenu = createSoundsMenu(); 
				
				helpMenu = this.pgmWindow.menu.addItem(new NativeMenuItem("Help")); 
				helpMenu.submenu = createHelpMenu();
				
				/*editMenu = this.pgmWindow.menu.addItem(new NativeMenuItem("Edit")); 
				editMenu.submenu = createEditMenu(); */
				
				Debug.log( "Native Window supports Menus" );
			} 
			
			if (NativeApplication.supportsMenu){ 
				NativeApplication.nativeApplication.menu.addEventListener(Event.SELECT, selectCommandMenu); 
				
				NativeApplication.nativeApplication.menu.removeItemAt(1);
				NativeApplication.nativeApplication.menu.removeItemAt(1);
				NativeApplication.nativeApplication.menu.removeItemAt(1); //Le premier est enlevé donc le deuxième est passé à l'index 1
				//NativeApplication.nativeApplication.menu.removeAllItems();
				
				firstMenu = NativeApplication.nativeApplication.menu.items[0];
				if( firstMenu.submenu.getItemAt( 2 ).label != PREFS ) {
					prefsCommand = firstMenu.submenu.addItemAt( new NativeMenuItem( PREFS ), 2 ); 
					firstMenu.submenu.addItemAt(new NativeMenuItem("Separator", true), 3); 
					prefsCommand.addEventListener(Event.SELECT, selectCommand); 	
				}
				
				fileMenu = NativeApplication.nativeApplication.menu.addItemAt(new NativeMenuItem("File"), 1); 
				//fileMenu = NativeApplication.nativeApplication.menu.items[1];
				fileMenu.submenu = createFileMenu();
				
				soundsMenu = NativeApplication.nativeApplication.menu.addItemAt(new NativeMenuItem("Sounds"), 2); 
				soundsMenu.submenu = createSoundsMenu();
				
				helpMenu = NativeApplication.nativeApplication.menu.addItem(new NativeMenuItem("Help")); 
				helpMenu.submenu = createHelpMenu();
				
				Debug.log( "Native Application supports Menus" );
			}  
			
			fileMenu.submenu.addEventListener(Event.DISPLAYING, updateSaveState);  
		}
		
		private function createFileMenu():NativeMenu { 
			var fileMenu:NativeMenu = new NativeMenu(); 
			fileMenu.addEventListener(Event.SELECT, selectCommandMenu); 
			
			var newCommand:NativeMenuItem = fileMenu.addItem(new NativeMenuItem( NEW_FILE )); 
			newCommand.addEventListener(Event.SELECT, selectCommand); 
			newCommand.keyEquivalent = "n"; 	
			
			var openCommand:NativeMenuItem = fileMenu.addItem(new NativeMenuItem( OPEN )); 
			openCommand.addEventListener(Event.SELECT, selectCommand); 
			openCommand.keyEquivalent = "o"; 			
			
			var openRecentMenu:NativeMenuItem = fileMenu.addItem(new NativeMenuItem( OPEN_RECENT ));  
			openRecentMenu.submenu = new NativeMenu(); 
			openRecentMenu.submenu.addEventListener(Event.DISPLAYING, updateRecentDocumentMenu); 
			openRecentMenu.submenu.addEventListener(Event.SELECT, selectCommandMenu); 
			
			var closeCommand:NativeMenuItem = fileMenu.addItem(new NativeMenuItem( CLOSE )); 
			closeCommand.addEventListener(Event.SELECT, selectCommand);
			closeCommand.keyEquivalent = "w"; 
			
			fileMenu.addItem(new NativeMenuItem("Separator", true)); 
			
			/* -------  SAVE ------- */
			var saveCommand:NativeMenuItem = fileMenu.addItem(new NativeMenuItem( SAVE )); 
			saveCommand.submenu = new NativeMenu();
			saveCommand.enabled = false;
			
			var savePGM:NativeMenuItem = saveCommand.submenu.addItem( new NativeMenuItem( PGM_ONLY ) );
			savePGM.addEventListener(Event.SELECT, selectSaveCommand); 
			savePGM.keyEquivalent = "s";
			
			var saveWSounds:NativeMenuItem = saveCommand.submenu.addItem( new NativeMenuItem( WITH_SOUNDS ) );
			saveWSounds.addEventListener(Event.SELECT, selectSaveCommand); 
			saveWSounds.keyEquivalent = "a";
			/*saveCommand.addEventListener(Event.SELECT, selectCommand); 
			saveCommand.enabled = false;*/
			
			/* -------  SAVE AS ------- */
			var saveAsCommand:NativeMenuItem = fileMenu.addItem(new NativeMenuItem( SAVE_AS )); 
			saveAsCommand.submenu = new NativeMenu();
			
			var saveAsPGM:NativeMenuItem = saveAsCommand.submenu.addItem( new NativeMenuItem( PGM_ONLY+"..." ) );
			saveAsPGM.addEventListener(Event.SELECT, selectSaveAsCommand); 
			saveAsPGM.keyEquivalent = "S";
			
			var saveAsWSounds:NativeMenuItem = saveAsCommand.submenu.addItem( new NativeMenuItem( WITH_SOUNDS+"..." ) );
			saveAsWSounds.addEventListener(Event.SELECT, selectSaveAsCommand); 
			saveAsWSounds.keyEquivalent = "A";
			
			if (NativeWindow.supportsMenu){ 
				var quitCommand:NativeMenuItem = fileMenu.addItem(new NativeMenuItem( QUIT )); 
				quitCommand.addEventListener(Event.SELECT, selectCommand);
				quitCommand.keyEquivalent = "q"; 
			}
			
			//saveAsCommand.addEventListener(Event.SELECT, selectCommand); 
			//saveAsCommand.keyEquivalent = "S"; 			
			
			return fileMenu; 
		}
		
		private function createEditMenu():NativeMenu { 
			var editMenu:NativeMenu = new NativeMenu(); 
			editMenu.addEventListener(Event.SELECT, selectCommandMenu); 
			
			var copyCommand:NativeMenuItem = editMenu.addItem(new NativeMenuItem("Copy")); 
			copyCommand.addEventListener(Event.SELECT, selectCommand); 
			copyCommand.keyEquivalent = "c"; 
			
			var pasteCommand:NativeMenuItem = editMenu.addItem(new NativeMenuItem("Paste")); 
			pasteCommand.addEventListener(Event.SELECT, selectCommand); 
			pasteCommand.keyEquivalent = "v"; 
			
			editMenu.addItem(new NativeMenuItem("", true)); 
			var preferencesCommand:NativeMenuItem = editMenu.addItem(new NativeMenuItem("Preferences")); 
			preferencesCommand.addEventListener(Event.SELECT, selectCommand); 
			
			return editMenu; 
		} 
		
		private function createSoundsMenu():NativeMenu { 
			var soundsMenu:NativeMenu = new NativeMenu(); 
			soundsMenu.addEventListener(Event.SELECT, selectCommandMenu); 
			
			var loadSoundsCommand:NativeMenuItem = soundsMenu.addItem(new NativeMenuItem( LOAD_SOUNDS )); 
			loadSoundsCommand.addEventListener(Event.SELECT, selectCommand); 
			loadSoundsCommand.keyEquivalent = "l"; 
			
			return soundsMenu; 
		} 
		
		private function createHelpMenu():NativeMenu { 
			var helpMenu:NativeMenu = new NativeMenu(); 
			helpMenu.addEventListener(Event.SELECT, selectCommandMenu); 
			
			var checkCommand:NativeMenuItem = helpMenu.addItem(new NativeMenuItem( CHECK_UPDATE )); 
			checkCommand.addEventListener(Event.SELECT, selectCommand);
			
			var helpCommand:NativeMenuItem = helpMenu.addItem(new NativeMenuItem( HELP )); 
			helpCommand.addEventListener(Event.SELECT, selectCommand); 
			
			var bugCommand:NativeMenuItem = helpMenu.addItem(new NativeMenuItem( BUG )); 
			bugCommand.addEventListener(Event.SELECT, selectCommand); 
			
			var donateCommand:NativeMenuItem = helpMenu.addItem(new NativeMenuItem( DONATE ));
			donateCommand.addEventListener(Event.SELECT, selectCommand); 
			
			return helpMenu; 
		} 
		
		private function updateSaveState(e:Event):void {
			trace( "Menus > updateSaveState " +getActiveWindow());
			var saveEnabled:Boolean = (getActiveWindow() != null) && ( getActiveWindow().originalFile != null ) && !getActiveWindow().hasBeenSaved;
			enableSaveMenu( saveEnabled );
		} 
		
		private function updateRecentDocumentMenu(event:Event):void { 
			trace("Updating recent document menu."); 
			var docMenu:NativeMenu = NativeMenu(event.target); 
			
			for each (var item:NativeMenuItem in docMenu.items) { 
				docMenu.removeItem(item); 
			} 
			
			for each (var file:File in recentDocuments) { 
				var menuItem:NativeMenuItem = docMenu.addItem(new NativeMenuItem(file.name)); 
				menuItem.data = file; 
				menuItem.addEventListener(Event.SELECT, selectRecentDocument); 
			} 
			
			if( recentDocuments.length < 1 ) {
				var subMenu:NativeMenuItem = docMenu.addItem( new NativeMenuItem( "No recent Documents" ) );
				subMenu.enabled = false;
			}
		} 
		
		private function selectRecentDocument(event:Event):void { 
			trace("Selected recent document: " + event.target.data.name); 
			
			/*fileOP = new FileOperations();
			var program:MPC2000 = fileOP.readPGMFile( File( event.target.data ) );*/
			var file:File = File( event.target.data );
			try {
				//var program:MPC2000 = readPGMFile( file );
				openDocument( file );
			} catch( e:Error ) {
				trace("error selectRecentDocument:  "+e.getStackTrace());
				removeFileFromRecentDocuments( file );
				Windows.showErrorWindow( "Sorry, this file doesn't exist anymore." );
			}
		} 
		
		private function selectCommand(event:Event):void { 
			trace("Selected command: " + event.target.label); 
			var soundFilter:FileFilter;
			
			switch ( event.target.label ) {
				case PREFS :
					var prefs:PrefWindow = new PrefWindow();
					break;
				case NEW_FILE :
					var saveMenu:NativeMenuItem = findMenuItem( SAVE );
					saveMenu.enabled = false;
					
					/*application.pgm = new MPC2000();
					application.mpc2000XL_mc.initMPCwithPGM( application.pgm );*/
					
					var pgmWindow:PGM_Window = new PGM_Window();
					pgmWindow.activate();
					break;
				case OPEN :
					/*fileOP = new FileOperations();
					fileOP.addEventListener(FileOperationsEvent.ON_PGM_LOADED, initPGM );
					fileOP.loadPGM();*/
					
					fileToSave = new File();
					soundFilter = new FileFilter("MPC 2000XL Program", "*.PGM");
					fileToSave.addEventListener( Event.SELECT, onPGMSelected );
					fileToSave.browse( [soundFilter] );
					break;
				case OPEN_RECENT :
					break;
				case CLOSE :
					NativeApplication.nativeApplication.activeWindow.close();
					break;
				case QUIT :
					NativeApplication.nativeApplication.exit();
					break;
				case SAVE :
					break;
				case SAVE_AS :
					/*fileOP = new FileOperations();
					fileOP.addEventListener( FileOperationsEvent.NAME_TOO_LONG, onNameTooLong );
					fileOP.savePGM( application.pgm );*/
					
					/*fileToSave = new File();
					//file.addEventListener(IOErrorEvent.IO_ERROR, onError );
					fileToSave.addEventListener(Event.SELECT, onSelectToSave);
					fileToSave.save( new ByteArray(), application.pgm.progName+".PGM" );*/
					break;
				case LOAD_SOUNDS :
					/*fileOP = new FileOperations();
					fileOP.addEventListener( FileOperationsEvent.ON_SAMPLES_LOADED, addSamples );
					fileOP.loadSoundFiles();*/
					
					/*fileList = new FileReferenceList();
					var soundFilter:FileFilter = new FileFilter("Sounds", "*.wav;*.snd;*.PGM");
					fileList.addEventListener( Event.SELECT, onSoundsSelected );
					fileList.browse( [soundFilter] );*/
					
					fileToSave = new File();
					soundFilter = new FileFilter("Sounds", "*.wav;*.snd");
					fileToSave.browseForOpenMultiple("Select sounds", [soundFilter] );
					fileToSave.addEventListener( FileListEvent.SELECT_MULTIPLE, onSoundsSelected );
					break;
				case CHECK_UPDATE :
					appUpdater = new AppUpdater();
					appUpdater.addEventListener( StatusUpdateEvent.UPDATE_STATUS, onCkeckUpdate );
					break;
				case HELP :
					Application.tracker.trackPageview( "/Help" );
					navigateToURL( new URLRequest( "http://mpc2000xlapp.com/help.html" ) );
					break;
				case BUG :
					Application.tracker.trackPageview( "/Send_Bug" );
					navigateToURL( new URLRequest( "http://www.mpc2000xlapp.com/contact.php" ) );
					break;
				case DONATE :
					Application.tracker.trackPageview( "/Donate" );
					navigateToURL( new URLRequest( "https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=FHW23XRTYS4PQ&lc=BS&item_name=Alexandre%20Soubrier%20%2d%20Tss%20Music&currency_code=EUR&bn=PP%2dDonationsBF%3abtn_donate_SM%2egif%3aNonHosted" ) );
					break;
				default:
					break;
			}
		}

		private function onCkeckUpdate(e:StatusUpdateEvent):void {
			if( !e.available ) {
				Windows.showErrorWindow( "Your application is up to date with v"+appUpdater.version); 
			}
			appUpdater.removeEventListener( StatusUpdateEvent.UPDATE_STATUS, onCkeckUpdate );
		}
		
		public static function getActiveWindow():PGM_Window {
			if( NativeApplication.nativeApplication.activeWindow is PGM_Window )
				return PGM_Window( NativeApplication.nativeApplication.activeWindow );
			else return null;
		}
		
		private function selectSaveCommand(e:Event):void {
			switch ( e.target.label ) {
				case PGM_ONLY :
					//saveProgram( application.pgm.pgmFileLoaded );
					saveProgram( getActiveWindow().originalFile );
					break;
				case WITH_SOUNDS :
					//saveProgram( application.pgm.pgmFileLoaded, true );
					saveProgram( getActiveWindow().originalFile, true );
					break;
				default:
					break;
			}
		}
		
		private function selectSaveAsCommand(e:Event):void 
		{
			trace("selectSaveAs");	
			switch ( e.target.label ) {
				case PGM_ONLY+"..." :
					fileToSave = new File();
					fileToSave.addEventListener(Event.SELECT, onSelectToSave);
					fileToSave.addEventListener(Event.COMPLETE, test );
					fileToSave.addEventListener(IOErrorEvent.IO_ERROR, test);
					//fileToSave.save( new ByteArray(), getActiveWindow().progName+".PGM" );
					fileToSave.browseForSave( "Save your file as..." );
					break;
				case WITH_SOUNDS+"..." :
					fileToSave = new File();
					fileToSave.addEventListener(Event.SELECT, onSelectToSaveWithSounds);
					fileToSave.addEventListener(Event.COMPLETE, test );
					fileToSave.addEventListener(IOErrorEvent.IO_ERROR, test);
					//fileToSave.save( new ByteArray(), getActiveWindow().progName+".PGM" );
					fileToSave.browseForSave( "Save your file as..." );
					break;
				default:
					break;
			}
		}
		
		function test(e:Event ) {
			trace(e);
		}

		/*private function onSoundsSelected(e:Event):void {
			trace( FileReferenceList( e.target ).fileList );
			var list:Array = FileReferenceList( e.target ).fileList;
			for (var i:int = 0; i < list.length; i++) {
				var file:FileReference = list[i] as FileReference;
				//var sample:SampleDatas = new SampleDatas( file.
				trace( file.name+"    "+File( file ).nativePath);
				application.pgm.addSample( file.name.slice(0, -4) );
			}
		}*/
		
		private function onSoundsSelected(e:FileListEvent):void {
			var list:Array = e.files;
			/*var samples:Array = new Array();
			for (var i:int = 0; i < list.length; i++) {
				var file:File = list[i] as File;
				var sampleName:String = file.name.slice(0, -4);
				var sample:SampleDatas = new SampleDatas( sampleName, file.nativePath );
				trace( file.name+"    "+ file.nativePath);
				samples.push( sample );
			}*/
			//application.pgm.addSamples( samples );
			
			var window:PGM_Window = getActiveWindow();
			var command:IUndoableCommand = new LoadSoundsCommand( list, window );
			command.execute();
		}
		
		/*
		* OPEN functions
		*/
		private function onPGMSelected(e:Event):void {
			/*application.pgm = readPGMFile( File( e.target ) );
			application.pgm.pgmFileLoaded = File( e.target );
			
			var fileIsInRecentDocument:Boolean = false;
			for (var i:int = 0; i < recentDocuments.length; i++) {
				if( File( recentDocuments[i] ).nativePath == File( e.target ).nativePath ) fileIsInRecentDocument = true;
			}
			if( !fileIsInRecentDocument ) recentDocuments.unshift( File( e.target ) );
			if( recentDocuments.length > MAX_RECENT_DOCUMENTS ) recentDocuments.pop();
			
			saveSharedObjects();
			
			application.mpc2000XL_mc.initMPCwithPGM( application.pgm );*/
			
			//var program:MPC2000 = readPGMFile( File( e.target ) );
			openDocument( File( e.target ) );
		}
		
		/*private function initPGM(e:FileOperationsEvent):void {
			openDocument( e.program, e.file );
		}*/
		
		private static function readPGMFile( file:File ):MPC2000 {
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.READ);
			
			var export:IO_PGM = new IO_PGM();
			var program:MPC2000 = export.readPGM( fileStream, file.resolvePath( ".." ).nativePath );
			fileStream.close();			
			
			return program;
		}
		
		/*
		* SAVE functions
		*/
		
		private function onSelectToSave(e:Event):void 
		{			
			saveProgram( File( e.target ) );
		}
		
		private function onSelectToSaveWithSounds(e:Event):void 
		{
			saveProgram( File( e.target ), true );
		} 
		
		private function saveProgram( file:File, withSounds:Boolean=false ):void 
		{
			trace( "Menu > saveProgram : file="+file.name+"; withSounds="+withSounds );
			saveWithSounds = withSounds;
			
			if( (file.name.slice(-4) != ".PGM" && file.name.slice(-4) != ".pgm") ) {
				file.nativePath += ".PGM";
			}
			
			//Mettre la longueur max du nom de fichier à 8 (sans compter le .PGM)
			if( file.name.slice(0,-4).length > GLOBAL.MAX_TEXT_LENGTH || GLOBAL.containsBadCharacters( file.name.slice(0,-4) ) ) {
				Debug.log(file.name+" = "+file.nativePath);
				Debug.log(file.exists);
				
				//errorBox = application.mpcInterface.showErrorBox();
				errorBox = getActiveWindow().mpcInterface.showErrorBox();
				errorBox.onSave = onSavingName;
				fileToSave = fileToSave.resolvePath("..");
			} else {
				writePGMFile( file, getActiveWindow().pgmDatas );
				
				var destination:File = file.resolvePath("..");
				if( withSounds ) saveSounds( destination );
				
				getActiveWindow().mpcInterface.screen_mc.updateName();
			}
		}
		
		private function writePGMFile( fileToSave:File, program:MPC2000 ):void {
			Debug.log( "Menus > writePGMFile : fileToSave="+fileToSave.nativePath+"; program="+program.progName );
			
			getActiveWindow().progName = fileToSave.name.slice(0,-4);
			getActiveWindow().title = fileToSave.name;
			getActiveWindow().hasBeenSaved = true;
			getActiveWindow().originalFile = fileToSave;
			
			var fileStream:FileStream = new FileStream();
			
			fileStream.addEventListener(Event.COMPLETE, completeHandler); 
			fileStream.addEventListener(ProgressEvent.PROGRESS, progressHandler); 
			fileStream.addEventListener(IOErrorEvent.IO_ERROR, errorHandler); 
			
			try {
				fileStream.openAsync(fileToSave, FileMode.WRITE);
			} catch(e:Error) {
				Debug.log( "Erreur d'opening :"+e.errorID+" : "+e.name+"  : "+e.message+"   getTrace:"+e.getStackTrace() );
			}
			Debug.log( "Menus > writePGMFile : fileStream="+fileStream );
			
			var export:IO_PGM = new IO_PGM();
			var bytesToWrite:ByteArray = export.writePGM( program );
			fileStream.writeBytes( bytesToWrite );
			fileStream.close();	
			
			addFileToRecentDocuments( fileToSave );
		}

		private function progressHandler(e:ProgressEvent):void {
			Debug.log( "On progress "+e);
		}

		private function completeHandler(e:Event):void {
			Debug.log( "on Complete "+e);
		}

		private function errorHandler(e:Event):void {
			Debug.log( "erreur "+e);
		}
		
		private function saveSounds( destination:File ):void {
			trace("saving Sounds");
			var fileTest:File = destination.resolvePath( "./Un nom.snd" );
			
			var nbreSamples:int = getActiveWindow().pgmDatas.samples.length;
			for (var i:int = 0; i < nbreSamples; i++) {
				var sample:SampleDatas = getActiveWindow().pgmDatas.samples[i] as SampleDatas;
				if( sample.filePath != null ) {
					var file:File = new File( sample.filePath );
					try{
						file.copyTo( destination.resolvePath( "./"+sample.name+"."+sample.extension ) );
					} catch(e:Error) {
						trace(e.message);
						trace(e.getStackTrace());
					}
				}
			}
		}

		private function onSavingName():void {
			trace( "ok je save "+ fileToSave.nativePath);
			
			var newName:String = errorBox.name_txt.text;			
			//writePGMFile( fileToSave.resolvePath( newName+".PGM" ), getActiveWindow().pgmDatas );
			saveProgram( fileToSave.resolvePath( newName+".PGM" ), saveWithSounds );
			
			errorBox.addEventListener( Event.CLOSE, onErrorClosed );
			getActiveWindow().mpcInterface.removeErrorBox( errorBox );
		}

		private function onErrorClosed(e:Event):void {			
			getActiveWindow().mpcInterface.showMessageBox( "Your file has been saved" );
		} 
		
		/*
		* LOAD FILES functions
		*/
		
		public static function alreadyExistingWindow( file:File ):PGM_Window {
			var nbreWindows:int = NativeApplication.nativeApplication.openedWindows.length;
			for (var i:int = 0; i < nbreWindows; i++) {
				var element:NativeWindow = NativeApplication.nativeApplication.openedWindows[i] as NativeWindow;
				trace( "Menus > alreadyExistingWindow : "+element, element is PGM_Window ,  file.nativePath );
				if( element is PGM_Window && PGM_Window( element ).originalFile != null ) trace( PGM_Window( element ).originalFile.nativePath, (PGM_Window( element ).originalFile.nativePath == file.nativePath) );
				if( element is PGM_Window && PGM_Window( element ).originalFile != null && PGM_Window( element ).originalFile.nativePath == file.nativePath ) {
					
					trace( "Menus > alreadyExistingWindow : elle existe"  );
					return PGM_Window( element );
				}
			}
			
			return null;
		}
		
		
		/** **/
		
		public static function openDocument( file:File ) {
			//application.pgm = program;
			//application.pgm.pgmFileLoaded = file;
			trace("Menus > openDocument( "+file.nativePath+" )");
			var program:MPC2000 = readPGMFile( file );
			var window:PGM_Window;
			
			/*if( NativeApplication.nativeApplication.activeWindow != null ) {
				window = getActiveWindow();
				var mpcInterface:DisplayObject = NativeApplication.nativeApplication.activeWindow.stage.getChildAt(0);
				if( mpcInterface is MPC2000XL && MPC2000XL( mpcInterface ).isEmpty() ) {
					trace( "Menus > openDocument : in empty doc" );
					//MPC2000XL( mpcInterface ).initMPCwithPGM( program );
					getActiveWindow().init( program, file );
				} else {
					trace( "Menus > openDocument : in a new doc" );
					//var existingWindow:PGM_Window = alreadyExistingWindow( file );
					//if( existingWindow != null ) existingWindow.activate();
					
					//Repérer si la fenêtre existe déjà
					var nbreWindows:int = NativeApplication.nativeApplication.openedWindows.length;
					var windowExists:Boolean = false;
					for (var i:int = 0; i < nbreWindows; i++) {
						var element:NativeWindow = NativeApplication.nativeApplication.openedWindows[i] as NativeWindow;
						if( element is PGM_Window && PGM_Window( element ).originalFile != null && PGM_Window( element ).originalFile.nativePath == file.nativePath ) {							
							trace( "Menus > alreadyExistingWindow : elle existe"  );
							windowExists = true;
							window = PGM_Window( element );
						}
					}
					
					if( !windowExists ) {
						window = new PGM_Window( program, file );
					}
				}
			} else*/ 
			if( NativeApplication.nativeApplication.openedWindows.length > 2 ) {
				var nbreWindows:int = NativeApplication.nativeApplication.openedWindows.length;
				var windowExists:Boolean = false;
				//parcourt toutes les fenêtres
				for (var i:int = 0; i < nbreWindows; i++) 
				{
					var element:NativeWindow = NativeApplication.nativeApplication.openedWindows[i] as NativeWindow;
					//si des fenêtre sont ouvertes
					if( element is PGM_Window ) 
					{						
						window = PGM_Window( element );
						trace("Menus > openDocument look at "+ window);
						
						var mpcInterface:DisplayObject = window.stage.getChildAt(0);
						//et que la fenêtre est vide, on remplit et on arrête
						if( mpcInterface is MPC2000XL && MPC2000XL( mpcInterface ).isEmpty() ) 
						{
							window.init( program, file );
							windowExists = true;
							break;
						} 
						//sinon, si la fenêtre existe déjà, on arrête la recherche
						else if( window.originalFile != null && window.originalFile.nativePath == file.nativePath ) 
						{							
								trace( "Menus > alreadyExistingWindow : elle existe "+window );
								windowExists = true;
								break;
						}
					} 
				}
				
				//et si aucune fenêtre n'est ni vide ni ouverte, on ajoute une fenêtre
				if( !windowExists ) {
					window = new PGM_Window( program, file );
				}
			} else {
				trace( "Menus > openDocument : no window opened" );
				window = new PGM_Window( program, file );
				/*window.originalFile = file;
				window.title = file.name;
				window.progName = file.name.slice(0,-4);*/
			}
			trace( "Menus > activate "+window);
			window.activate();
			
			addFileToRecentDocuments(file);
			
			//enableSaveMenu( false );
			
			//application.mpcInterface.initMPCwithPGM( program );
		}
		
		public function enableSaveMenu( enable:Boolean = true ) {
			var saveMenu:NativeMenuItem = findMenuItem( SAVE );
			saveMenu.enabled = enable;
			trace("menu save enabled = "+enable);
		}

		private static function addFileToRecentDocuments( file:File ):void {
			var fileIsInRecentDocument:Boolean = false;
			for (var i:int = 0; i < recentDocuments.length; i++) {
				if( File( recentDocuments[i] ).nativePath == file.nativePath ) {
					fileIsInRecentDocument = true;
					var tempFile:File = File( recentDocuments[i] );
					recentDocuments.splice( i, 1 );
					recentDocuments.unshift( tempFile );
				}
			}
			if( !fileIsInRecentDocument ) recentDocuments.unshift( file );
			if( recentDocuments.length > MAX_RECENT_DOCUMENTS ) recentDocuments.pop();
			
			saveSharedObjects();
		}
		
		private function removeFileFromRecentDocuments( file:File ):void {
			for (var i:int = 0; i < recentDocuments.length; i++) {
				if( File( recentDocuments[i] ).nativePath == file.nativePath ) {
					recentDocuments.splice( i, 1 );
				}
			}
			
			saveSharedObjects()
		}
		
		private static function saveSharedObjects():void {
			var pathRecentDocuments:Array = new Array();
			for (var i:int = 0; i < recentDocuments.length; i++) {
				pathRecentDocuments[i] = File( recentDocuments[i] ).nativePath;
			}
			
			Application.saveSharedObjects( pathRecentDocuments, "pathRecentDocuments" );
		}


		/*private static function saveSharedObjects():void {
			var pathRecentDocuments:Array = new Array();
			for (var i:int = 0; i < recentDocuments.length; i++) {
				pathRecentDocuments[i] = File( recentDocuments[i] ).nativePath;
			}
			Application.sharedObject.data.pathRecentDocuments = pathRecentDocuments;
			
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
						trace("Value flushed to disk.\n");
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
		}*/
		
		private function selectCommandMenu(event:Event):void { 
			if (event.currentTarget.parent != null) { 
				var menuItem:NativeMenuItem = findItemForMenu(NativeMenu(event.currentTarget)); 
				if (menuItem != null) { 
					trace("Select event for \"" +  
						event.target.label +  
						"\" command handled by menu: " +  
						menuItem.label); 
				} 
			} else { 
				trace("Select event for \"" +  
					event.target.label +  
					"\" command handled by root menu."); 
			} 
		} 
		
		private function findMenuItem( menuItem:String ):NativeMenuItem {
			var menu:NativeMenu; 			
			
			if (NativeWindow.supportsMenu) 
				menu = pgmWindow.menu;
			if (NativeApplication.supportsMenu)
				menu = NativeApplication.nativeApplication.menu;
			
			for each (var item:NativeMenuItem in menu.items) {
				for each (var subMenuItem:NativeMenuItem in item.submenu.items ){
					if( subMenuItem.label == menuItem ) {
						return subMenuItem;
					}
				}
			}
			return null;
		}
		
		private function findItemForMenu(menu:NativeMenu):NativeMenuItem { 
			for each (var item:NativeMenuItem in menu.parent.items) { 
				if (item != null) { 
					if (item.submenu == menu) { 
						return item; 
					} 
				} 
			} 
			return null; 
		} 
	} 
}