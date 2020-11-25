package UI
{
	import Interface.Menus;
	
	import flash.display.MovieClip;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.ui.Keyboard;
	
	import org.moonpalace.utils.KeycodeNames;
	
	public class PrefWindow extends NativeWindow
	{
		private var textFields:Array = ["pad1_txt","pad2_txt","pad3_txt","pad4_txt","pad5_txt","pad6_txt",
								"pad7_txt","pad8_txt","pad9_txt","pad10_txt","pad11_txt","pad12_txt","pad13_txt","pad14_txt","pad15_txt","pad16_txt"];
		private var tempkeys:Array = new Array();
		
		public function PrefWindow()
		{
			var initOptions:NativeWindowInitOptions = new NativeWindowInitOptions();
			initOptions.maximizable = false;
			initOptions.resizable = false;
			initOptions.systemChrome = NativeWindowSystemChrome.STANDARD; 
			initOptions.type = NativeWindowType.UTILITY;
			super(initOptions);
			
			var prefs:MovieClip = new PrefsPads();
			for (var i:int = 0; i < textFields.length; i++) {
				var element:String = textFields[i] as String;
				var textField:TextField = TextField( prefs[element] );
				
				textField.autoSize = TextFieldAutoSize.CENTER;
				textField.selectable = false;
				if( KeycodeNames.getKeyName( Application.HOTKEYS[i] ) != "NULL" ) 
					textField.text = KeycodeNames.getKeyName( Application.HOTKEYS[i] );		
				else textField.text = Application.KEYNAMES[i];
				
				textField.addEventListener( FocusEvent.FOCUS_IN, onFocus );
				//textField.addEventListener( Event.CHANGE, onChange );
				
				tempkeys[i] = Application.HOTKEYS[i];
				textField.tabIndex = i;
			}
			
			with( prefs ) {
				reset_btn.addEventListener( MouseEvent.CLICK, reset );
				save_mc.addEventListener(MouseEvent.CLICK, save );
				cancel_mc.addEventListener(MouseEvent.CLICK, cancel );
				x = 0;
				y = 0;
			}
			
			this.x = 300;
			this.y = 200;
			this.stage.scaleMode = StageScaleMode.NO_SCALE; 
			this.stage.align = StageAlign.TOP_LEFT; 
			this.stage.stageWidth = prefs.width; 
			this.stage.stageHeight = prefs.height; 
			this.stage.addChild( prefs ); 
			this.alwaysInFront = true; 
			this.visible = true;
			this.activate();
			
			stage.addEventListener( KeyboardEvent.KEY_DOWN, onKeyboard );
		}

		private function onChange(event:Event):void
		{
			trace("**** .text = "+TextField( event.target ).text );
			TextField( event.target ).text = TextField( event.target ).text.toUpperCase();
		}

		private function onFocus(e:FocusEvent):void {
			var tField:TextField = TextField( e.target );
			setFocus( tField );
			
			trace( "focus = "+stage.focus+"   "+tField.text.length );
		}

		private function onFocusOut(event:FocusEvent):void
		{
			var tField:TextField = TextField( event.target );
			removeFocus( tField );
		}
		
		private function setFocus( tField:TextField ) {
			stage.focus = tField;
			tField.background = true;
			tField.backgroundColor = 0x4A100E;
			
			tField.addEventListener( FocusEvent.FOCUS_OUT, onFocusOut );
		}
		
		private function removeFocus( tField:TextField ) {
			tField.background = false;
			tField.removeEventListener( FocusEvent.FOCUS_OUT, onFocusOut );
		}

		
		/**
		 * Handles the keyboard shortcuts.
		 * Be carefull : Air returns 186 for the M letter, instead of 76. So we have to save a letter tab AND a keycode tab.
		 * @param e
		 * 
		 */
		private function onKeyboard(e:KeyboardEvent):void {
			var tField:TextField;
			if( stage.focus is TextField ) {
				tField = TextField( stage.focus );
				
				for (var i:int = 0; i < textFields.length; i++) {
					var fieldName:String = textFields[i] as String;
					var textField:TextField = TextField( this.stage.getChildAt(0)[fieldName] );
					if( textField === tField ) {
						var index:int = i;
						break;
					}
				}
			}
				
			switch (e.keyCode) {
				case Keyboard.TAB:
					removeFocus( tField );
					var next:String = textFields[ (index+1)%16 ];
					setFocus( TextField( this.stage.getChildAt(0)[ next ] ) );
					break;
				case Keyboard.ENTER:
					save();
					break;
				default:
					if( tField != null ) {
						if( KeycodeNames.getKeyName( e.keyCode ) != "NULL" )
							tField.text = KeycodeNames.getKeyName( e.keyCode );
						else {
							tField.text = String.fromCharCode( e.charCode ).toUpperCase();
						}
						tempkeys[index] = e.keyCode;
					}
					break;
			}
		}

		private function cancel(e:MouseEvent):void {
			var prefs:MovieClip = MovieClip( this.stage.getChildAt(0) );
			for (var i:int = 0; i < textFields.length; i++) {
				var padName:String = textFields[i] as String;
				var textField:TextField = TextField( prefs[padName] );
				textField.text = Application.KEYNAMES[i];	
			}
			this.close();
		}

		private function save(e:MouseEvent=null):void {
			Application.HOTKEYS = tempkeys;
			for (var i:int = 0; i < textFields.length; i++) {
				var element:String = textFields[i] as String;
				Application.KEYNAMES[i] = TextField( this.stage.getChildAt(0)[element] ).text;
			} 
			Application.saveSharedObjects( tempkeys, "hotkeys" );
			Application.saveSharedObjects( Application.KEYNAMES, "keyNames" );

			this.close();
		}
		
		private function reset(e:MouseEvent=null):void {
			var prefs:MovieClip = MovieClip( this.stage.getChildAt(0) );
			for (var i:int = 0; i < textFields.length; i++) {
				var padName:String = textFields[i] as String;
				var textField:TextField = TextField( prefs[padName] );
				tempkeys[i] = Application.defaultKeys[i];
				textField.text = Application.defaultKeyNames[i];	
			}
		}
	}
}