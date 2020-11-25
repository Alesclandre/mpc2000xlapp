package MPC2000XL_PGM
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class PadBanks
	{
		public static const NBR_PADS:int = 16;
		public static const BANK_A:String = "A";
		public static const BANK_B:String = "B";
		public static const BANK_C:String = "C";
		public static const BANK_D:String = "D";
		
		public var tabPads:Array;
		
		public function PadBanks()
		{
			tabPads = new Array( NBR_PADS * 4 );
			
			initInChromaticOrder();
		}			
		
		/**
		 * Initialize all the Midi Notes in the chromatic order (on the MPC, it is a mess)
		 * @return 
		 * 
		 */
		public function initInChromaticOrder():void {			
			var note:int = 35;
			for( var i:int = 0; i < NBR_PADS * 4; i++ ) tabPads[i] = new Pad( i, note++ );
		}
		
		public function getNoteOnPad( padNumber:int ):int {
			trace("**** "+padNumber+"    "+tabPads[ padNumber ] );
			return Pad( tabPads[ padNumber ] ).numeroNote;
		}
		
		public function getPadFromNote( noteNumber:int ):int {
			for (var i:int = 0; i < tabPads.length; i++) {
				var pad:Pad = tabPads[i] as Pad;
				if( pad.numeroNote == noteNumber ) return i;
			}
			return -1;
		}
		
		/**
		 * Get the samples on each bank.
		 * @param whichBank Select the bank for which you want to get the samples.
		 * @return An array of samples.
		 * 
		 */
		public function getSamplesOnPadBank( whichBank:String ):Array {
			var tab:Array;
			var beginIndex:int;
			switch( whichBank ) {
				case BANK_A :
					beginIndex = 0;
					break;
				case BANK_B :
					beginIndex = NBR_PADS;
					break;
				case BANK_C :
					beginIndex = NBR_PADS * 2;
					break;
				case BANK_D :
					beginIndex = NBR_PADS * 3;
					break;
				default : 
					beginIndex = 0;
					break;
			}
			tab = tabPads.slice( beginIndex, beginIndex + NBR_PADS );
			return tab;
		}
		
		public static function getMPCPadName( padID:int ):String {
			var bank:int = int( padID / 16 );
			var bankName:String;
			if( bank == 0 ) bankName = "A";
			else if( bank == 1 ) bankName = "B";
			else if( bank == 2 ) bankName = "C";
			else if( bank == 3 ) bankName = "D";
			var number:int = int( padID % 16 )+1;
			var numName:String;
			if( number < 10 ) numName = "0"+number.toString();
			else numName = number.toString();
			
			return bankName+numName;
		}
		
		/*public function assign( tabPad:Array, numeroPad:int, numeroNote:int ) {
			tabPad[numeroPad] = numeroNote;
		}*/
		
		/**
		 * Write the byte in order to send them to the PGM file format
		 * @return byteArray
		 * 
		 */
		public function writeBytes():ByteArray {
			var b:ByteArray = new ByteArray();
			b.endian = Endian.LITTLE_ENDIAN;
			for( var i:int = 0; i < NBR_PADS * 4; i++ ) {
				b.writeByte( Pad( tabPads[i] ).numeroNote );
			}
			return b;
		}
		
		/**
		 * Read the bytes from a pgm file format.
		 * @param byte
		 * @return byteArray
		 * 
		 */
		public function readBytes( byte:ByteArray ) {
			byte.position = 0;
			for( var i:int = 0; i < NBR_PADS * 4; i++ ) tabPads[i] = byte.readByte();
		}
		
		public function toString():String {
			return "[PadAssign tabA="+tabPads+"]";
		}
	}
}