package org.moonpalace.utils
{
	
	/**
	 * ...
	 * @author DefaultUser (Tools -> Custom Arguments...)
	 */
	public class MathExt
	{
		
		public static function sign( pN:Number ):Number {
			var temp:Number;
			
			if ( pN != 0 )  {
				temp = Math.abs(pN) / pN;
				return temp;
			} else return 1;
			
		}
		
		public static function toRad( pAngle:Number ):Number {
			return pAngle * Math.PI / 180;
		}
		
		public static function toDegree( pAngleRad:Number ):Number {
			return pAngleRad * 180 / Math.PI;
		}
		
		public static function randRange(min:Number, max:Number):Number {
			var rand:Number = min + (max - min) * Math.random();
			return rand;
		}
		
		public static function interpolation(value1:Number, value2:Number, amt:Number):Number {
			return value1+(value2-value1)*amt;
		}
		
		/**
		 * Re-maps a number from range 1 to range 2.
		 * @param value 
		 * @param low1
		 * @param high1
		 * @param low2
		 * @param high2
		 * @param isInsideLimites
		 * @return 
		 * 
		 */
		public static function map( value:Number, low1:Number, high1:Number, low2:Number, high2:Number, isInsideLimites:Boolean=false ):Number {
			if( isInsideLimites ) {
				value = Math.min( value, Math.max( low1, high1 ) );
				value = Math.max( value, Math.min( low1, high1) );
			}
			var percent:Number = (high1 != low1) ? (value - low1) / (high1 - low1 ) : 0;
			return low2 + percent * (high2 - low2);
		}
		
		public static function randomSign():int {
			var a:Array = new Array(-1,1);
			var s:int = a[ int( Math.random() * 2 ) ];
			return s;
		}
		
		public static function toHexColor( number:uint ) {
			var string:String = number.toString(16).toUpperCase();			
			while (6 > string.length) {
				string = "0" + string;
			}			
			string = "0x" + string;			
			return string;			
		}
		
		public static function distance( x1, y1, x2, y2):Number {
			return Math.sqrt( Math.pow((x1-x2),2) + Math.pow((y1-y2),2) );
		}
		
		/**
		 * Calcule une somme de 0 à n de v à la puissance n
		 * @param v valeur dont on veut faire la somme
		 * @param n valeur de la puissance sur laquelle on doit faire la somme
		 * @return 
		 * 
		 */
		public function somme( v:Number, n:int ):Number {
			var result:Number = Math.pow( v, n );
			if( n > 1 ) {
				result += somme( v, n-1 );
			}
			else result += 1;
			
			return result;
		}
		
	}
	
}