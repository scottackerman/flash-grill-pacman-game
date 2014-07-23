package swingpants.components
{
	/**
	 * GradiatedSpikes
	 * 
	 * @author	Jon Howard	[@swingpants] www.swingpants.com
	 * 
	 * Class to build a pattern of gradiated spikes from a centre point
	 */
	
    import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel
	import flash.display.GradientType
	import flash.filters.BlurFilter
    import flash.display.Sprite;
	import flash.geom.Point;
	
	import flash.geom.Matrix


    public class GradiatedSpikes extends Sprite 
	{
		private var blur:BlurFilter=new BlurFilter()

		private var centre_point:Point 
		private var max_line_length:Number
		
		/**
		 * CONSTRUCTOR
		 * 
		 * @param	w
		 * @param	h
		 * @param	num_spikes
		 */
		public function GradiatedSpikes(w:int=256,h:int=256, num_spikes:int=250):void
		{
			max_line_length=Math.min(w,h)*0.5
			centre_point = new Point(w * 0.5, h * 0.5)

			var gradientBoxMatrix:Matrix = new Matrix();
            gradientBoxMatrix.createGradientBox(w, h, 0, 0, 0); 
			
			for (var i:int = 0; i < num_spikes; i++)
				{
					drawSpike(w,h,gradientBoxMatrix)
				}
			this.filters=[blur]
		}
		
		/**
		 * drawSpike	-	
		 * @param	w
		 * @param	h
		 */
		private function drawSpike(w:int,h:int, gradient_matrix:Matrix):void
		{
			graphics.lineStyle(1, 0, 0.9)
			
			graphics.lineGradientStyle(GradientType.RADIAL, [0xFFFFFF, 0x999999, 0x000000], [0.8, 0.6, 0.2], [0, 92, 196], gradient_matrix);
			graphics.moveTo(centre_point.x, centre_point.y)
			var draw_to:Point = centre_point.clone()
			moveForward(draw_to, max_line_length * Math.random(), Math.random() * 360)
			graphics.lineTo(draw_to.x,draw_to.y)
		}
		
		/**
		 * Move a target point forward at a given rotation
		 * @param	target
		 * @param	dist
		 * @param	rot
		 */
		private function moveForward(target:Point, dist:Number, rot:Number):void
		{
			var radi:Number = rot * (Math.PI / 180);
			var to_x:Number = target.x + dist * Math.sin(radi);
			var to_y:Number = target.y - dist * Math.cos(radi);
			target.x = to_x
			target.y = to_y
		}
		
	}
 
}