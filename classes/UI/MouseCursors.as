package UI
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.ui.Mouse;
	import flash.ui.MouseCursorData;

	public class MouseCursors
	{
		public static const HAND:String = "handCursor";
		public static const CLOSED_HAND:String = "closedHandCursor";
		public static const ADD_SELECTION:String = "addSelectionCursor";
		public static const REMOVE_SELECTION:String = "removeSelectionCursor";
		public static const MODIFY:String = "modifySelectionCursor";
		
		public function MouseCursors()
		{
			
		}
		
		public static function addNewCursor(cursorName:String, bitmapData:BitmapData, posX:int=7, posY:int = 7):void {
			var cursorData:MouseCursorData = new MouseCursorData();
			cursorData.hotSpot = new Point(posX,posY);
			var bitmapDatas:Vector.<BitmapData> = new Vector.<BitmapData>( 1, true);
			
			// The bitmap must be 32x32 pixels or smaller, due to an OS limitation
			//var bitmap:Bitmap = new cursorClass();
			bitmapDatas[0] = bitmapData;//bitmap.bitmapData;
			cursorData.data = bitmapDatas;
			Mouse.registerCursor(cursorName, cursorData);
		}
	}
}