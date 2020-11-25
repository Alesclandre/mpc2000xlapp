package commandPattern.commands
{
	import Interface.Graphics.Pads.Pad_Interface;
	
	import MPC2000XL_PGM.SampleDatas;
	
	import UI.PGM_Window;

	public class RemoveSampleCommand implements IUndoableCommand
	{
		private var activeWindow:PGM_Window;
		private var sample:SampleDatas;
		private var pads:Array;
		
		public function RemoveSampleCommand( sample:SampleDatas, window:PGM_Window )
		{
			this.activeWindow = window;
			this.sample = sample;
			pads = window.mpcInterface.getNotesAndPadsFromSampleName( sample.name ).pads;
		}
		
		public function execute():void {
			activeWindow.pgmDatas.removeSample( sample );
			activeWindow.mpcInterface.refreshAll();
			activeWindow.history.push( this );
		}
		
		public function undo():void {
			if( pads != null ) {
				var lng:int = pads.length;
				for (var i:int = 0; i < pads.length; i++)
				{
					activeWindow.pgmDatas.addSample( sample, pads[i] );
				}
			}
			activeWindow.mpcInterface.refreshAll();
			activeWindow.history.pop();
		}
		
	}
}