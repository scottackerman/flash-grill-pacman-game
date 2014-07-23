package swingpants.components
{
    import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel
	import flash.filters.BlurFilter
    import flash.display.Sprite;

    public class PerlinNoise extends Sprite 
	{

		private var bmd:BitmapData
		private var seed:Number = Math.random()*256
		private var channels:uint =  BitmapDataChannel.BLUE | BitmapDataChannel.ALPHA;
		private var bmp:Bitmap 

		private var blur:BlurFilter=new BlurFilter()

		public function PerlinNoise(w:int=256,h:int=256):void
		{
			bmd = new BitmapData(w, h, true, 0x00000000);
			bmp = new Bitmap(bmd);
			init();
		}
		

		private function init():void
		{
			bmd.perlinNoise(32, 32, 16, seed, true, true, channels, true, null);
			addChild(bmp)
			filters=[blur]
		}
		
	}
 
}