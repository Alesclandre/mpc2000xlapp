package MPC2000XL_PGM
{
	public class Pad
	{
		private var _numeroPad:int;
		private var _numeroNote:int;
		
		public function Pad( numeroPad:int, numeroNote:int )
		{
			_numeroPad = numeroPad;
			_numeroNote = numeroNote;
		}
		
		public function get ID():int {
			return _numeroPad;
		}

		public function set numeroNote(value:int):void {
			_numeroNote = value;
		}

		
		public function get numeroNote():int {
			return _numeroNote;
		}
		
		public function toString():String {
			return "[Pad numeroPad ="+_numeroPad+" numeroNote="+_numeroNote+" ]";
		}

	}
}