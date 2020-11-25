package Interface
{
	import MPC2000XL_PGM.IO_PGM;
	import MPC2000XL_PGM.MPC2000;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.net.FileReferenceList;
	import flash.utils.ByteArray;

	public class FileOperations extends EventDispatcher
	{
		
		private var fileList:FileReferenceList;
		private var file:File;
		private var program:MPC2000;
		private var fileStream:FileStream

		public function FileOperations()
		{
		}
		
		public function loadPGM():void {
			var file:File = new File();
			var soundFilter:FileFilter = new FileFilter("MPC 2000XL Program", "*.PGM");
			file.addEventListener( Event.SELECT, onPGMSelected );
			file.browse( [soundFilter] );
		}
		
		public function readPGMFile( file:File ):MPC2000 {
			fileStream = new FileStream();
			fileStream.open(file, FileMode.READ);
			
			var export:IO_PGM = new IO_PGM();
			var program:MPC2000 = export.readPGM( fileStream, file.resolvePath( ".." ).nativePath );
			fileStream.close();			
			
			return program;
		}
		
		public function writePGMFile( fileToSave:File, program:MPC2000 ):void {
			var fileStream:FileStream = new FileStream();
			fileStream.open(fileToSave, FileMode.WRITE);
			
			var export:IO_PGM = new IO_PGM();
			fileStream.writeBytes( export.writePGM( program ) );
			fileStream.close();	
		}
		
		private function onPGMSelected(e:Event):void {
			var program:MPC2000 = readPGMFile( File( e.target ) );
			dispatchEvent( new FileOperationsEvent( FileOperationsEvent.ON_PGM_LOADED, false, false, program, null, File( e.target ) ) );
		}
		
		public function copyFile( file:File ):void {
			if( file != null ) {
				try{
					var destination:File = file.resolvePath("..");
					file.copyTo( destination.resolvePath("DOSSIER/test.wav") );
				} catch(e:Error) {
					trace(e.message);
					trace(e.getStackTrace());
				}
			}
		}
		
		public function loadSoundFiles():void {
			fileList = new FileReferenceList();
			var soundFilter:FileFilter = new FileFilter("Sounds", "*.wav;*.snd;*.PGM");
			fileList.addEventListener( Event.SELECT, onSoundsSelected );
			fileList.browse( [soundFilter] );
		}
		
		private function onSoundsSelected(e:Event):void {
			/*var fileStream:FileStream = new FileStream();
			fileStream.open(File(e.target), FileMode.READ);
			//var str:String = fileStream.readMultiByte(file.size, File.systemCharset);
			fileStream.position = 0;
			trace("fichier : "+fileStream.endian+"   "+fileStream.readByte());
			trace(fileStream.readByte());
			trace(fileStream.readByte());
			trace(fileStream.readByte());
			trace(fileStream.readByte());
			fileStream.close();*/
			
			/*trace( "Files : "+fileList.fileList[0].name );
			var sampleNames:Array = new Array();
			for (var i:int = 0; i < fileList.fileList.length; i++) {
				var n:String = fileList.fileList[i].name;
				if( fileList.fileList[i] != null ) {
					n = n.slice(0,-4);
					sampleNames.push( n );
				}
				trace(n);
				//pgm.addSample( n );
			}*/
			
			dispatchEvent( new FileOperationsEvent( FileOperationsEvent.ON_SAMPLES_LOADED, false, false, null, fileList.fileList ) );
		}
		
		public function savePGM( program:MPC2000 ) {
			this.program = program;
			trace("file = "+file);
			file = new File();
			//file.addEventListener(IOErrorEvent.IO_ERROR, onError );
			file.addEventListener(Event.SELECT, onSelect);
			//file.save( pgm.writePGM(), pgm.progName+".PGM" );	
			var savePGM:IO_PGM = new IO_PGM();
			//file.save( savePGM.writePGM( program ), program.progName+".PGM" );
			file.save( new ByteArray(), program.progName+".PGM" );
		}

		private function onError(e:IOErrorEvent):void {
			trace(e);
		}
		
		private function onSelect(e:Event):void 
		{			
			var nameInput:String = File( e.target ).name;
			nameInput = nameInput.slice(0,-4); //Enlever .PGM
			
			if( nameInput.length > 16 ) {
				trace(File( e.target ).name+" = "+File( e.target ).nativePath);
				trace(File( e.target ).exists);
				
				File( e.target ).deleteFile();
				dispatchEvent( new FileOperationsEvent( FileOperationsEvent.NAME_TOO_LONG,false,false,null,null,File(e.target ) ) );
			} else {
				program.progName = nameInput;
				nameInput = nameInput+".PGM";
				
				writePGMFile( File( e.target ), program );
			}
			file = null;
			/*nameInput = nameInput.slice( 0, 16);//Raccourcir le nom
			program.progName = nameInput;//Renommer le nom interne du programme
			nameInput = nameInput+".PGM";
			var newFile:File = File( e.target ).resolvePath("../"+nameInput);//Renommer le fichier du même nom que le nom du programme, sinon ça ne marche pas sur la MPC
			//File( e.target ).deleteFile();
			
			var savePGM:IO_PGM = new IO_PGM();
			writePGMFile( newFile, program );
			
			trace("nom fichier : "+File( e.target ).name);
			trace("adresse fichier : "+File( e.target ).nativePath);
			trace("extension fichier : "+File( e.target ).extension);
			if( file != null ) {
				var dossier:String = "DOSSIER";
				var destination:File = File( e.target ).resolvePath("..");
				//file.copyTo( destination.resolvePath(dossier+"/s01.wav") );
				//File( e.target ).moveTo( destination.resolvePath(dossier+"/"+File( e.target ).name) );
			}*/
		}
	}
}