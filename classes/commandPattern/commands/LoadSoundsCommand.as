package commandPattern.commands
{
	import Interface.Menus;
	
	import MPC2000XL_PGM.MPC2000;
	
	import UI.PGM_Window;
	
	import flash.desktop.NativeApplication;

	public class LoadSoundsCommand implements IUndoableCommand
	{
		private var activeWindow:PGM_Window;
		private var sampleFiles:Array;
		private var startPadID:int;
		
		public function LoadSoundsCommand( sampleFiles:Array, window:PGM_Window, startPadID:int=0 )
		{
			this.activeWindow = window;
			this.sampleFiles = sampleFiles;
			this.startPadID = startPadID;
		}
		
		public function execute():void {
			activeWindow.pgmDatas.addSamples( sampleFiles, startPadID );
			activeWindow.mpcInterface.refreshAll();
			activeWindow.history.push( this );
		}
		
		public function undo():void {
			activeWindow.pgmDatas.removeSamples( sampleFiles );
			activeWindow.mpcInterface.refreshAll();
			activeWindow.history.pop();
		}
	}
}