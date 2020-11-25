/**
* WaveSoundEvent by Denis Kolyako. May 28, 2007
* Visit http://dev.etcs.ru for documentation, updates and more free code.
*
* You may distribute this class freely, provided it is not modified in any way (including
* removing this header or changing the package path).
* 
*
* Please contact etc[at]mail.ru prior to distributing modified versions of this class.
*/
package events {
	import flash.events.Event;

	public class WaveSoundEvent extends Event {
		/*
		* *********************************************************
		* CLASS PROPERTIES
		* *********************************************************
		*
		*/
		public static const DECODE_ERROR:String = 'decodeError';

		/*
		* *********************************************************
		* CONSTRUCTOR
		* *********************************************************
		*
		*/
		public function WaveSoundEvent(type:String,bubbles:Boolean=false,cancelable:Boolean=false) {
			super(type,bubbles,cancelable);
		}
	}
}