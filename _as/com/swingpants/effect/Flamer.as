package com.swingpants.effect 
{
	
	/**
	 * FLAMER
	 * 
	 * @author	Jon Howard	[@swingpants] www.swingpants.com
	 * 
	 * Based on Saqoosha's Fire (http://wonderfl.net/code/bffb3437de866ffdfcdd5015b1fba5ca37fff72a)
	 * - I found the perlin noise rendering a little too slow for my needs
	 *   so I render 2 panels of perlin noise. Additive blend them, rotate one and grab a draw of the result on each frame
	 * - I draw a colour gradient for flame colouring. This replaces a png dependency.
	 */
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.ConvolutionFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;

	
	import flash.geom.Matrix
	import flash.display.GradientType
	import flash.display.SpreadMethod


	public class Flamer extends Sprite 
	{

		private static const ZERO_POINT:Point = new Point();
		
		public static const ORANGE_FLAME:int = 0
		public static const BLUE_FLAME:int = 1
		public static const YELLOW_FLAME:int = 2
		public static const GREEN_FLAME:int=3

		
		public static const COLOUR_ARRAY:Array = [ { colours:[0x0, 0xff6600, 0xFFCC32, 0xff3300], ratios: [0, 128, 220, 255] }, //RED/ORANGE
													{colours:[0x0, 0x0000FF, 0x2299FF, 0xFFFFFF], ratios:[0, 128, 220, 255] }, //BLUE
													{colours:[0x0, 0x666600, 0xbbCC32, 0xFFCC00], ratios:[0, 128, 220, 255] }, //YELLOW
													{colours:[0x0, 0x006600, 0x22CC22, 0x99FF99], ratios:[0, 128, 220, 255] }, //GREEN
													{colours:[0x0, 0x440044, 0x990099, 0xFF00FF], ratios: [0, 128, 220, 255] }//PURPLE
												  ]
		private var colour_index:int = 0 
		
		private var size_w:int = 512
		private var size_h:int = 512
		
		private var fire_colour:BitmapData;
		
		private var canvas:Sprite;
		private var grey_bmd:BitmapData;
		private var convolution:ConvolutionFilter;
		private var cooling_bmd:BitmapData;
		private var colour_mfilter:ColorMatrixFilter;

		private var fire_bmd:BitmapData; // final bitmapdata to display
		private var palette_array:Array; //Array of colour values for the paletteMap
		private var zero_array:Array; //Array full of zeros for paletteMap
		
		private var colour_source:Sprite//Colour gradient that is picked from
		private var display_obj:DisplayObject//The object that is 'on fire'
		
		private var perlin_1:Bitmap
		private var perlin_2:Bitmap
		
		private var bmp_holder:Sprite = new Sprite()
		private var pnoise_container:Sprite = new Sprite()
		
		private var fire_bmp:Bitmap//Container for the displayed flame
		
		private var flame_dir:Point=new Point(0,-3)
		
		private var largeScale:Boolean
		
		/**
		 * CONSTRUCTOR
		 */
		public function Flamer(display_object:DisplayObject, w:int=512, h:int=512, flame_direction:Point=null, scale:Boolean=false) 
		{
			size_w = w
			size_h = h
			
			if (flame_direction)flame_dir=flame_direction.clone()
			
			display_obj = display_object
			
			initFireColours()
			initPerlinNoise()
			
			largeScale = scale;
			
			init()
		}
		
		/**
		 * setFlameColour	-	A method to set flames to a preset colour: ORANGE_FLAME, BLUE_FLAME, YELLOW_FLAME, GREEN_FLAME
		 * @param	val
		 */
		public function setFlameColour(val:int):void
		{
			if (val >= COLOUR_ARRAY.length || val < 0) val = 0
			colour_index = val
			initFireColours()
		}
		
		public function setFlameDirection(val:Point):void
		{
			flame_dir=val.clone()
		}
		/**
		 * initFireColours
		 * Construct the colour gradient palette for the chosen fire
		 */
		private function initFireColours():void
		{
			fire_colour = createColourGradient(COLOUR_ARRAY[colour_index].colours, COLOUR_ARRAY[colour_index].ratios)
			createPalette();
		}
		
		/**
		 * createColourGradient	-	Build the colour gradient and copy into  bitmapData
		 * @param	colours_array
		 * @param	ratios_array
		 * @return	BitmapData of the colour gradient - for use with colour picking in the paletteMap
		 */
		private function createColourGradient(colours_array:Array, ratios_array:Array):BitmapData
		{
			var bmd:BitmapData = new BitmapData(256, 5, false, 0)
			var colour_source:Sprite = new Sprite()
			
			var mat:Matrix = new Matrix();
			mat.createGradientBox(256, 5, 0, 0, 0);
			colour_source.graphics.beginGradientFill(GradientType.LINEAR, colours_array, [1,1,1,1], ratios_array, mat, SpreadMethod.PAD);
			colour_source.graphics.drawRect(0, 0, 256, 20);
			bmd.draw(colour_source)
		
			return bmd
		}
		
		/**
		 * createPalette - build an array of 256 colour values - the fire gradient
		 */
		private function createPalette():void 
		{
			palette_array = [];
			zero_array = [];
			for (var i:int = 0; i < 256; i++) 
			{
				palette_array.push(this.fire_colour.getPixel(i, 1));//Pick the colour values
				zero_array.push(0);
			}
		}
		
		/**
		 * initPerlinNoise - Build the two perlin noise bitmaps and add to their respective containers
		 */
		private function initPerlinNoise():void
		{
			perlin_1 = new Bitmap(makePerlinNoise(size_w, size_h))
			pnoise_container.addChild(perlin_1)
			
			perlin_2 = new Bitmap(makePerlinNoise(size_w, size_h))
			perlin_2.blendMode = BlendMode.DIFFERENCE
			perlin_2.x = -size_w*0.5
			perlin_2.y = -size_h*0.5
			bmp_holder.x = size_w*0.15
			bmp_holder.y = size_h*0.15
			
			bmp_holder.addChild(perlin_2)
			pnoise_container.addChild(bmp_holder)
		}
		
		/**
		 * init	-	Initialise all the elements for the Flamer class
		 */
		private function init():void 
		{
			canvas = new Sprite();
		//	display_obj = fuelSprite()//The fuel sprite is the seed to create the fire - the thing that is on fire
			canvas.addChild(display_obj);
			
			grey_bmd = new BitmapData(size_w, size_h, false, 0x0); //Grey scale bitmap for working on
			convolution = new ConvolutionFilter(3, 3, [0, 1, 0,  1, 1, 1,  0, 1, 0], 5); //The convolution filter - checks each pixel and filters according to matrix
			cooling_bmd = new BitmapData(size_w, size_h, false, 0x0);
			
			fire_bmd = new BitmapData(size_w, size_h, false, 0x0);//The final flame bitmapdata
			fire_bmp = new Bitmap(fire_bmd) 
			fire_bmp.blendMode=BlendMode.ADD
			addChild(fire_bmp);
			
			createCooling(0.8); //Calm down the flames  (0 - lots, 1 - fewer)

		}

		
		/**
		 * createCooling	-	ColourMatrixFilter to calm down the flames. The fire extinguisher
		 * @param	a	-	Colour transform level
		 */
		private function createCooling(a:Number):void 
		{
			colour_mfilter = new ColorMatrixFilter([
				a, 0, 0, 0, 0,
				0, a, 0, 0, 0,
				0, 0, a, 0, 0,
				0, 0, 0, 1, 0
			]);
		}
		
		/**
		 * update	-	Main frame update
		 * @param	event
		 */
		public function update(event:Event=null):void 
		{
			if(largeScale) {
				bmp_holder.scaleY = bmp_holder.scaleX = 3
			}
			bmp_holder.rotation += 2//Rotate the perlin noise
			

			//Draw the canvas tot he grey bitmapdata, then runt he convolution filter
			grey_bmd.draw(canvas);
			grey_bmd.applyFilter(grey_bmd, grey_bmd.rect, ZERO_POINT, convolution);

			//Draw the perlin noise into the cooling_bmd and apply the cooling
			cooling_bmd.draw(pnoise_container)
			cooling_bmd.applyFilter(cooling_bmd, cooling_bmd.rect, ZERO_POINT, colour_mfilter);

			//Draw the cooling into the grey bitmapdata with Subraction blending
			grey_bmd.draw(cooling_bmd, null, null, BlendMode.SUBTRACT);
			grey_bmd.scroll(flame_dir.x, flame_dir.y);
			
			//Reassign the colours in the grey bitmapdata to those from the palette_array
			fire_bmd.paletteMap(grey_bmd, grey_bmd.rect, ZERO_POINT, palette_array, zero_array, zero_array, zero_array);
		}
		
		/**
		 * makePerlinNoise	-	Construct a perlin noise bitmapdata
		 * @param	w
		 * @param	h
		 * @param	octaves
		 * @return
		 */
		private function makePerlinNoise(w:int,h:int, octaves:int=4):BitmapData
		{
			var bmd:BitmapData = new BitmapData(w, h, false, 0)
			bmd.perlinNoise(50, 50, octaves, Math.random() * 512, true, false, 0, true);
			return bmd
		}
	}
}