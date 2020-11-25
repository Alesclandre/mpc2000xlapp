package
{
	import Interface.Graphics.MPC2000XL;
	
	import MPC2000XL_PGM.MPC2000;

	public class Controller
	{
		private var pgm:MPC2000;
		private var interfaceWindow:MPC2000XL;
		
		public function Controller(pgm:MPC2000, interfaceWindow:MPC2000XL)
		{
			this.pgm = pgm;
			this.interfaceWindow = interfaceWindow;
		}
		
		public function loadSounds( sounds:String ):void {
			
		}
		
		public function saveSounds( sounds:String):void {
			
		}
		
		public function addSounds( sounds:String ):void {
			
		}
		
		public function addSoundOnPad( sound:String, padNumber:int ):void {
			
		}
		
		public function deleteSoundOnPad( padNumber:int ):void {
			
		}
		
		public function changeSoundName( soundFileName:String, newSoundName:String ):void {
			
		}
		
		public function savePGM():void {
			
		}
		
		public function savePGMwithSounds():void {
			
		}
	}
}