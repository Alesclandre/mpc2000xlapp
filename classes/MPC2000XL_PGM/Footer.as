package MPC2000XL_PGM
{
	import flash.utils.ByteArray;

	public class Footer extends ByteArray
	{
		public function Footer()
		{
			var footer:String = "02 00 48 00 D0 07 00 00 63 01 14 08 1D FC 32 33 02 32 3C 08 05 0A 14 14 32 00 00 02 0F 19 00 05 41 14 1E 01 05 00 00 05 63 00 F4 FF 0C 00 00 00 00 00 00 00 02 00 4F 01 4F 01 00 42 4F 01 00 42 4F 01 00 42 32 00 63 28 00 3C 00 00 D0 07 00 00 63 01 14 08 1D FC 32 33 02 32 3C 08 05 0A 14 14 32 00 00 02 0F 19 00 05 41 14 1E 01 05 00 00 05 63 00 F4 FF 0C 00 00 00 00 00 00 00 02 00 4F 01 4F 01 00 42 4F 01 00 42 4F 01 00 42 32 00 63 28 00 3C 00 00 04 00 0C 00 00 00 32 00 23 00 3E 33 5A 32 14 00 00 00 32 00 23 00 3E 33 5A 32 14 00 00 00 32 00 23 00 3E 33 5A 32 14 00 00 00 32 00 23 00 3E 33 5A 32 14 00";
			
			var len:uint = footer.length;
			for (var i:uint = 0; i < len; i += 3) {
				var c:String = '0x' + footer.charAt(i) + footer.charAt(i + 1);				
				writeByte(parseInt(c));
			}

		}
	}
}