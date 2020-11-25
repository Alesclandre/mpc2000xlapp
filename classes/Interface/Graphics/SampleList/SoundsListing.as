package Interface.Graphics.SampleList
{
	import MPC2000XL_PGM.MPC2000;
	import MPC2000XL_PGM.SampleDatas;
	
	import commandPattern.commands.IUndoableCommand;
	import commandPattern.commands.LoadSoundsCommand;
	
	import events.SoundsListingEvent;
	
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeDragManager;
	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	
	import gs.TweenLite;
	import gs.easing.Strong;
	
	public class SoundsListing extends MovieClip
	{
		private const increment:Number = 33;
		
		private var samplesContainer:Sprite;
		private var samplesList:Array;
		private var flecheListing:MovieClip;
		private var order:uint = 0;
		private var sortFeature:String = "sortingNotes";
		public var pgm:MPC2000;
		
		public var lift_mc:LiftClip = new LiftClip();
		public var mask_mc:MovieClip = new MovieClip();
		public var sounds_mc:MovieClip = new MovieClip();
		public var pads_mc:MovieClip = new MovieClip();
		public var notes_mc:MovieClip = new MovieClip();
		
		public function SoundsListing()
		{
			super();
			tabChildren = false;
			
			flecheListing = new FlecheListing();
			
			addChild( flecheListing );
			
			samplesContainer = new Sprite();
			samplesContainer.x = 9;
			samplesContainer.y = 33;
			samplesContainer.mask = mask_mc;
			addChild( samplesContainer );
			
			samplesList = new Array();
			
			sounds_mc.buttonMode = pads_mc.buttonMode = notes_mc.buttonMode = true;
			sounds_mc.addEventListener( MouseEvent.CLICK, onHeaderClick );
			pads_mc.addEventListener( MouseEvent.CLICK, onHeaderClick );
			notes_mc.addEventListener( MouseEvent.CLICK, onHeaderClick );
			replaceFleche( notes_mc );
			trace( "SoundsListing constructor" );
			
			addEventListener( NativeDragEvent.NATIVE_DRAG_ENTER, onDraggingOnPad );
		}
		
		public function disableAllMouseEvents() {
			var lng:int = samplesList.length;
			for( var i:int=0; i<lng; i++ ) {
				SampleClip( samplesList[i] ).disableMouseEvents();
			}
		}
		
		public function enableAllMouseEvents() {
			var lng:int = samplesList.length;
			for( var i:int=0; i<lng; i++ ) {
				SampleClip( samplesList[i] ).enableMouseEvents();
			}
		}

		public function selectNextSample( sample:SampleDatas ):void {
			trace("j'ai entendu ton dispatch");
			var next:int = -1;
			var lng:int = samplesList.length;
			for( var i:int=0; i<lng-1; i++ ) {
				if( SampleClip( samplesList[i] ).sample == sample ) {
					SampleClip( samplesList[i+1] ).selectName();
					break;
				}
			}
			
			if( SampleClip( samplesList[lng-1] ).sample == sample ) {
				stage.focus = null;
			}
		}

		private function onDraggingOnPad(e:NativeDragEvent):void {
			NativeDragManager.acceptDragDrop( InteractiveObject( e.currentTarget ) );
			e.currentTarget.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, handleDragDrop );
		}
		
		private function handleDragDrop(e:NativeDragEvent):void {
			e.currentTarget.removeEventListener(NativeDragEvent.NATIVE_DRAG_DROP, handleDragDrop );
			
			var files:Array = Clipboard( e.clipboard ).getData( ClipboardFormats.FILE_LIST_FORMAT ) as Array;
			var goodSamples:Array = new Array();
			for (var i:int = 0; i < files.length; i++) {
				var file:File = File( files[i] );
				var ext:String = String( file.extension ).toLowerCase();
				if( ext == "wav" || ext == "snd" ) {
					//var sample:SampleDatas = new SampleDatas( file.name.slice(0,-4), file.nativePath );
					goodSamples.push( file );
				}
			}
			
			dispatchEvent( new SoundsListingEvent( SoundsListingEvent.ADD_SAMPLES, null, goodSamples ) );
		}
		
		public function init() {	
			lift_mc.init( samplesContainer, increment );
			trace( "SoundsListing init" );
		}
		
		public function setPGM( pgm:MPC2000 ) {
			this.pgm = pgm;
		}
		
		public function update():void {
			samplesList.sortOn( sortFeature, order );
			sortSamples();
			lift_mc.update();
		}
		
		public function selectName( sample:SampleDatas ):void {
			for( var i:int=0; i<samplesList.length; i++) {
				if( sample == SampleClip( samplesList[i] ).sample ) {
					SampleClip( samplesList[i] ).selectName();
					break;
				}
			}
		}
		
		public function renameSampleFromTextField( sample:SampleDatas ) {
			for( var i:int=0; i<samplesList.length; i++) {
				if( sample == SampleClip( samplesList[i] ).sample ) {
					SampleClip( samplesList[i] ).renameSampleFromTextField();
					break;
				}
			}
		}
		
		public function isSampleInListing( sampleName:String ):Boolean {
			for (var i:int = 0; i < samplesList.length; i++)
			{
				if( SampleClip( samplesList[i] ).sample.name == sampleName ) return true;
			}
			return false;
		}
		
		public function thereIsAnotherName( sample:SampleDatas, name:String ):Boolean {
			var lng:int = samplesList.length;
			for( var i:int=0; i< lng; i++ ) {
				if( SampleClip( samplesList[i] ).sample != sample && SampleClip( samplesList[i] ).sample.name == name ) {
					return true;
				}
			}
			return false;
		}
		
		public function updateSampleClip( sampleName:String ) {
			var sampleClip:SampleClip = getSampleClipFromsampleName( sampleName );
		}
		
		public function getSampleClipFromsampleName( sampleName:String ):SampleClip {
			for (var i:int = 0; i < samplesList.length; i++) {
				var sample:SampleClip = samplesList[i] as SampleClip;
				if( sample.sample.name == sampleName ) 
					return sample;
			}
			return null;
		}

		private function onHeaderClick(e:MouseEvent):void {
			replaceFleche( MovieClip( e.target ) );
			order = 0;
			if( flecheListing.scaleY < 0 ) order = Array.DESCENDING;
			switch( e.target ) {
				case sounds_mc :
					order = order | Array.CASEINSENSITIVE;
					sortFeature = "sortingName";
					break;
				case pads_mc :
					order = order | Array.NUMERIC; //Sinon, 10 passe avant 2
					sortFeature = "sortingPads";
					break;
				case notes_mc :
					order = order | Array.NUMERIC; 
					sortFeature = "sortingNotes";
					break;
				default :
					break;
			}
			update();
		}
		
		private function sortSamples() {
			for (var i:int = 0; i < samplesList.length; i++) {
				var sample:SampleClip = samplesList[i] as SampleClip;
				//sample.y = i * increment;
				TweenLite.to( sample, .5, {y:i * increment, ease:Strong.easeOut } );
			}
		}
		
		private function replaceFleche( whichClip:MovieClip ) {
			var posFleche:Number = flecheListing.x;
			sounds_mc.x = 40;
			pads_mc.x = 158;
			notes_mc.x = 230;
			if( posFleche == whichClip.x ) flecheListing.scaleY = -flecheListing.scaleY;
			
			flecheListing.x = whichClip.x;
			flecheListing.y = (flecheListing.scaleY > 0 ) ? whichClip.y + 4 : whichClip.y + 7;
			
			whichClip.x = whichClip.x + 10;
		}
		
		public function addSample(sampleDatas:SampleDatas, notes:Array=null, pads:Array=null):void 
		{
			var sample:SampleClip = new SampleClip(sampleDatas,notes,pads);
			sample.y = samplesContainer.numChildren * increment;
			//sample.deleteFunction = removeSample;
			sample.deleteFunction = pgm.removeSample;
			sample.playSound = pgm.playSound;
			samplesContainer.addChild( sample );
			samplesList.push( sample );
			lift_mc.update();
		}
		
		public function removeSample( sampleDatas:SampleDatas ) {
			trace( "remove Sample" );
			for (var i:int = 0; i < samplesList.length; i++)
			{
				var sample:SampleClip = samplesList[i] as SampleClip;
				if( sampleDatas.name == sample.sample.name ) {
					samplesList.splice( i, 1 );
					samplesContainer.removeChild( sample );
				}
			}
			//pgm.removeSample( sampleName );
			update();
		}
		
		public function updateSample( sampleDatas:SampleDatas, notes:Array, pads:Array):void {
			for (var i:int = 0; i < samplesContainer.numChildren; i++) {
				var sampleClip:SampleClip = samplesContainer.getChildAt(i) as SampleClip;
				if( sampleClip.son_txt.text == sampleDatas.name ) {
					sampleClip.updateSample( sampleDatas, notes, pads );
				}
			}
		}
		
		public function destroyAll() {
			var children:int = samplesContainer.numChildren;
			while( children-- ) samplesContainer.removeChildAt( children );		
			samplesList = new Array();
		}
		
		/*public function updateSampleList( samples:Array ):void {
			samplesList = samples;
			for (var i:int = 0; i < samples.length; i++) {
				var sample:Sample = samples[i] as Sample;
				sample.updateSample( samples[i], , );
			}
		}*/
	}
}