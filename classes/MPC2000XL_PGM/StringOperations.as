package MPC2000XL_PGM
{
	public class StringOperations
	{
		public function StringOperations()
		{
		}
		
		static function removeFinalSpaces( name:String ):String {
			var l:int = name.length-1;
			while( name.charCodeAt( l ) == 0x20 ) {
				name = name.slice( 0, l );
				l--;
			}
			return name;
		}
	}
}