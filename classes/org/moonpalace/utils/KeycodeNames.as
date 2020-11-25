package org.moonpalace.utils
{
	public class KeycodeNames
	{
		//Get keycode from charCode
		static public const KEYCODE_NAMES:Object = {
			8:"Backsp.",
			9:"Tab",
			13:"Enter",
			15:"Cmd",
			16:"Shift",
			17:"Ctrl",			
			18:"Alt",			
			20:"CapsL.",
			27:"Esc",
			32:"Space",
			33:"P. Up",
			34:"P. Down",
			35:"End",
			36:"Home",
			37:"Left",
			38:"Up",
			39:"Right",
			40:"Down",
			45:"Insert",
			46:"Delete",
			144:"NumLock",
			145:"ScrLk",
			19:"Pause",
			96:"Num. 0",
			97:"Num. 1",
			98:"Num. 2",
			99:"Num. 3",
			100:"Num. 4",
			101:"Num. 5",
			102:"Num. 6",
			103:"Num. 7",
			104:"Num. 8",
			105:"Num. 9",
			106:"Num. *",
			107:"Num. +",
			13:"Num. Ent.",
			109:"Num. -",
			110:"Num. ,",
			111:"Num. /",
			112:"F1",
			113:"F2",
			114:"F3",
			115:"F4",
			116:"F5",
			117:"F6",
			118:"F7",
			119:"F8",
			120:"F9",
			121:"F10",
			122:"F11",
			123:"F12",
			124:"F13",
			125:"F14",
			126:"F15"			
		}
		static public const KEYCODE_NAMES_AZERTY:Object = {
			186:";",
			187:"=",
			189:"-",
			191:"/",
			192:"`",
			219:"[",
			220:"\\", 
			221:"]",
			222:"\"",
			188:",",
			189:".",
			191:"/"			
		}
			
		public static function getKeyName( keycode:int ):String {
			//if keycode is a letter or a number
			/*if( (keycode >= 65 && keycode <= 90) ||  (keycode >= 48 && keycode <= 57) ) {
				return String.fromCharCode( keycode );
			} */
			return KEYCODE_NAMES[keycode] ? KEYCODE_NAMES[keycode] : "NULL";
		}
		
	}
}