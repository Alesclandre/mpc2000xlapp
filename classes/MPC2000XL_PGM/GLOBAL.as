package MPC2000XL_PGM
{
	public class GLOBAL
	{
		public static const MAX_TEXT_LENGTH:int = 8;
		public static const BAD_STRINGS:String = "àáâãäåéèêëìíîïòóôõöùúûüýÿçñÉÈÊËÀÁÂÇÔ'’ ";
		public static const GOOD_STRINGS:String = "aaaaaaeeeeiiiiooooouuuuyycnEEEEAAACO___";
		
		public function GLOBAL()
		{
		}
		
		public static function renameForMPC( texte:String ):String {
			if( texte.length > MAX_TEXT_LENGTH ) texte = texte.slice(0,MAX_TEXT_LENGTH);
			if( texte.charAt(7) == "." ) texte = texte.replace(".", "_");	
			
			for (var i:Number = 0; i<BAD_STRINGS.length; i++) {
				while(texte.indexOf(BAD_STRINGS.charAt(i)) != -1){
					texte = texte.replace(BAD_STRINGS.charAt(i), GOOD_STRINGS.charAt(i));					
				}
			} 
			
			return texte;
		} 
		
		public static function containsBadCharacters( texte:String ):Boolean {
			for (var i:Number = 0; i<BAD_STRINGS.length; i++) {
				if(texte.indexOf(BAD_STRINGS.charAt(i)) != -1){
					return true;				
				}
			} 
			return false;
		}
	}
}