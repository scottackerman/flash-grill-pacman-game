package swingpants.components
{
	/**
	 * ExplosionPattern
	 * 
	 * @author	Jon Howard	[@swingpants] www.swingpants.com
	 * 
	 * A pattern of explosion to seed the Flamer class
	 * A number of bubbles that rush to expand then recede more slowly.
	 * 
	 * This pattern needs updating if 'active' is true
	 */
	
    import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel
	import flash.events.Event;
	import flash.filters.BlurFilter
    import flash.display.Sprite;
	/**
	 * 
	 */
    public class ExplosionPattern extends Sprite 
	{
		private var exp_bubbles:Array = []
		private var exp_scalers:Array = []
		private var num_bubbles:int = 5
		
		private var current_max_scale:Number = 2
		
		public var active:Boolean=false

		/**
		 * CONSTRUCTOR
		 */
		public function ExplosionPattern():void
		{
			for (var i:int = 0; i < num_bubbles; i++)
				{
					var s:Sprite = new Sprite()
					addChild(s)
					s.graphics.beginFill(0xFF0000)
					s.graphics.drawCircle(0, 0, 10)
					s.graphics.endFill()
					exp_bubbles.push(s)
					exp_scalers.push(1.1)
				}
		}
		
		/**
		 * explode	-	Start an explosion
		 * @param	max_scale
		 */
		public function explode(max_scale:Number=3):void
		{
			active=true
			current_max_scale = max_scale*0.9+Math.random()*10
			
			for (var i:int = 0; i < num_bubbles; i++)
				{
					exp_scalers[i] = 1.05 + Math.random() * 0.35
					if (exp_bubbles[i].scaleX < 0.1)
						{
							exp_bubbles[i].scaleX = 0.1
							exp_bubbles[i].scaleY = 0.1
						}
					exp_bubbles[i].x = max_scale*3 - Math.random() * max_scale*6
					exp_bubbles[i].y = max_scale*3 - Math.random() * max_scale*6
				}
		}

		/**
		 * update	-	step update (oef)
		 * @param	event
		 */
		public function update(event:Event=null):void
		{
			var end_tally:int=0
			for (var i:int = 0; i < num_bubbles; i++)
				{
					exp_bubbles[i].scaleX = exp_bubbles[i].scaleY *= exp_scalers[i]
					if (exp_bubbles[i].scaleX>current_max_scale)
						{
							exp_bubbles[i].scaleX=exp_bubbles[i].scaleY=current_max_scale
							exp_scalers[i]=0.999-Math.random()*0.1
						}
						else
					if (exp_bubbles[i].scaleX < 0.1)
						{
							end_tally++
						}
				}
			if (end_tally == num_bubbles)
				{
					active=false
				}
		}
		
	}
 
}