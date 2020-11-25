package org.moonpalace
{
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.events.Event;
	import flash.text.TextFormat;
	
	public class MaTrace extends Sprite
	{
		public static var texte:TextField;
		public static const MARGE:Number = 10;
		
		public static var fond:Sprite;
		private static var numeroLigne:int = 0;
		
		public function MaTrace( largeur:Number=200, hauteur:Number=500, ...args  ) {
			fond = new Sprite();
			fond.graphics.beginFill( 0x000000, .2 );
			fond.graphics.drawRect( 0, 0, 100, 100);
			fond.graphics.endFill();
			addChild( fond );
			
			var format:TextFormat = new TextFormat();			
			format.color = 0xFFFFFF;
			format.size = 12;
			format.font = 'Arial';
			
			texte = new TextField();
			texte.defaultTextFormat = format;
			texte.width = largeur;
			texte.height = hauteur;
			texte.autoSize = TextFieldAutoSize.NONE;
			texte.wordWrap = true;
			texte.selectable = true;
			texte.x = MARGE;
			texte.y = MARGE;
			texte.text = "";	
			addChild( texte );
			
			var lng:int = args.length;
			for ( var i:int = 0 ; i < lng ; i++ ) {
				//texte.text += args[i];
				texte.appendText( args[i] );
			}		
			
			fond.width = texte.width + 2 * MARGE;
			fond.height = texte.height + 2 * MARGE;
		}
		
		public static function tracer( ...args ) {
			if( texte != null ) {
				var chaine:String = "";
				var lng:int = args.length;
				for ( var i:int = 0 ; i < lng ; i++ ) {
					chaine += args[i];
				}
				//texte.text += "\n" + chaine;
				texte.appendText( "\n" + numeroLigne + ". " + chaine );
				numeroLigne ++;
				
				fond.width = texte.width + 2 * MARGE;
				fond.height = texte.height + 2 * MARGE;
				
				texte.scrollV = texte.maxScrollV;
			} 
		}
		
		public static function showChildren( clip:DisplayObjectContainer ) {
			var lng:int = clip.numChildren;
			trace("/////  showChildren");
			for (var i:int = 0; i < clip.numChildren; i++) {
				tracer( "clip.getChildAt("+i+") = "+clip.getChildAt(i) );
				trace( "clip.getChildAt("+i+") = "+clip.getChildAt(i) );
			}
			trace("/////  end showChildren");
		}
		
	}
	
}