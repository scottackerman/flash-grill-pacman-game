package {
	import flash.net.*;
	import flash.utils.*;
	import flash.events.*;
	import flash.display.*;
	import flash.external.*;
	
	import com.greensock.*;
	import com.greensock.easing.*;
	import com.greensock.plugins.*;
	
	import com.swingpants.effect.Flamer;
	
	public class GrillMan_Nationals_728x90 extends MovieClip {
		private var grillFire:Flamer;
		private var bgFlame:Flamer;
		private var grillScale:Number = .13;
		private var largeGrillScale:Number = .16;
		private var grillFacingLeft:Boolean;
		private var grillMouth:MovieClip;
		private var fireGrillMouth:MovieClip;
		private var grillHub:MovieClip;
		private var fireGrillHub:MovieClip;
		private var stageWidth:uint;
		private var stageHeight:uint;
		private var grillMovementIncrement:uint = 100;
		private var halfGrillWidth:Number = 26;
		private var MEAT_ARRAY:Array = new Array('Hotdog', 'Corn', 'Chicken', 'Burger', 'Steak');
		private var MEAT_ARRAY_VALUES:Array = new Array(100, 50, 350, 200, 500);
		private var MEAT_MAX_DROP_SPEED_ARRAY:Array = new Array(3, 3.3, 2.2, 2.6, 2);
		private var MIN_DROP_SPEED:Number = .1;
		private var WHEEL_SPIN_TIMES:Number = 5;
		private var gameTimer:Timer;
		private var dropItemTimer:Timer;
		private var autoGamePlayTimer:Timer;
		private var gameTime:uint = 15;
		private var DROP_DELAY_INTERVAL_MAX:Number = 1000;
		private var DROP_DELAY_INTERVAL_MIN:Number = 200;
		private var score:Number = 0;
		private var play_again_btn;
		private var gameOn:Boolean;
		private var autoGamePlay:Boolean;
		private var playBgFlame:Boolean;
		private var autoPlayKeyCounter:Number = 0;
		private var main_btn:MovieClip;
		private var teaser_btn:MovieClip;
		private var legal_mc:MovieClip;
		
		private const MOUTH_SPEED:Number = .3;
		private const MOUTH_OPEN_POSITION:Number = -25;
		
		public function GrillMan_Nationals_728x90() {
			stageWidth = 600;
			stageHeight = stage.stageHeight;
			grillFire = new Flamer(grill_fire_mc, 600, 600, null, true);
			addChild(grillFire);
			bgFlame = new Flamer(paperCover_mc, 728, 728, null, true);
			addChild(bgFlame);
			grillMouth = grill_mc.grill_top_mc;
			fireGrillMouth = grill_fire_mc.grill_top_mc;
			grillHub = grill_mc.front_wheel_mc.wheel_hub_mc;
			fireGrillHub = grill_fire_mc.front_wheel_mc.wheel_hub_mc;
			addEventListener(Event.ENTER_FRAME, updateFire);
			
			main_btn = new MainButton();
			main_btn.buttonMode = true;
			addChild(main_btn);
			main_btn.addEventListener(MouseEvent.ROLL_OVER, mainRollOverEvent);
			main_btn.addEventListener(MouseEvent.CLICK, mainClickEvent);
			main_btn.addEventListener(MouseEvent.ROLL_OUT, mainRollOutEvent);
			
			play_again_btn = new PlayAgainButton();
			play_again_btn.x = 539;
			play_again_btn.y = 54;
			play_again_btn.scaleX = play_again_btn.scaleY = .83;
			addChild(play_again_btn);
			play_again_btn.addEventListener(MouseEvent.MOUSE_OVER, revGrill);
			play_again_btn.addEventListener(MouseEvent.CLICK, playAgain);
			play_again_btn.addEventListener(MouseEvent.MOUSE_OUT, unRevGrill);
			
			teaser_btn = new Teaser();
			teaser_btn.buttonMode = true;
			addChild(teaser_btn);
			teaser_btn.addEventListener(MouseEvent.CLICK, teaserClickEvent);
			
			legal_mc = new Legal();
			legal_mc.buttonMode = true;
			legal_mc.y = 75;
			addChild(legal_mc);
			legal_mc.addEventListener(MouseEvent.MOUSE_OVER, legalRollOver);
			legal_mc.addEventListener(MouseEvent.MOUSE_OUT, legalRollOut);
			
			initBanner();
		}
		
		private function initBanner():void {
			autoGamePlay = true;
			play_again_btn.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			autoGamePlayTimer = new Timer(10, 0);
			autoGamePlayTimer.addEventListener(TimerEvent.TIMER, autoMove);
			autoGamePlayTimer.start();
		}
		
		private function playAgain(evt:Event):void {
			if(!autoGamePlay){
				//trackAction('Play_Again');
			}
			startGame(evt);
		}
		
		private function autoMove(evt:Event):void {
			var randomDirection;
			if(autoGamePlay) {
				if(autoPlayKeyCounter > 3) {
					grillFacingLeft = Boolean(Math.round(Math.random()));
				} else {
					grillFacingLeft = false;
				}
				moveGrill();
				autoGamePlayTimer.delay = (Math.random()*(DROP_DELAY_INTERVAL_MAX - DROP_DELAY_INTERVAL_MIN))+DROP_DELAY_INTERVAL_MIN;
				autoPlayKeyCounter++;
			}
		}
		
		private function startGrillMouth():void {
			openGrillMouth();
		}
		
		private function startGame(evt:Event):void {
			grill_fire_mc.scaleX = grill_fire_mc.scaleY = grill_mc.scaleX = grill_mc.scaleY = grillScale;
			score = 0;
			if(autoGamePlay) {
				gameTime = 10;
			} else {
				gameTime = 15;
			}
			gameOn = true;
			playBgFlame = false;
			play_again_btn.visible = false;
			scorePanel_mc.txt_score.text = String(score);
			scorePanel_mc.txt_timer.text = String(gameTime);
			paperCover_mc.gotoAndStop(1);
			gameTimer = new Timer(1000, 15);
			gameTimer.addEventListener(TimerEvent.TIMER, updateGameTime);
			gameTimer.start();
			dropItemTimer = new Timer(500, 0);
			dropItemTimer.addEventListener(TimerEvent.TIMER, dropItem);
			dropItemTimer.start();
			startGrillMouth();
			grill_mc.vectorFlames_mc.alpha = 0;
			grill_fire_mc.vectorFlames_mc.alpha = 0;
			TweenLite.to(grill_fire_mc, .5, {alpha:1, ease:Quad.easeOut});
			TweenLite.to(bg_mc, .2, {alpha:1, ease:Quad.easeIn});
			TweenLite.to(paperCover_mc, 0, {alpha:0, scaleX:1, scaleY:1, ease:Quad.easeIn});
			TweenLite.to(scorePanel_mc, .2, {alpha:1, ease:Quad.easeOut});
			stage.addEventListener(KeyboardEvent.KEY_DOWN, gameKeyPressed);
		}
		
		private function updateGameTime(evt:TimerEvent):void {
			gameTime--;
			scorePanel_mc.txt_timer.text = String(gameTime);
			if(scorePanel_mc.txt_timer.text == "0"){
				gameTimer.removeEventListener(TimerEvent.TIMER, updateGameTime);
				gameOn = false;
				gameOver();
			}
		}
		
		private function gameOver():void {
			gameOn = false;
			autoGamePlay = false;
			playBgFlame = true;
			teaser_btn.visible = false;
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, gameKeyPressed);
			grill_mc.scaleX = grillScale;
			grill_fire_mc.scaleX = grillScale;
			TweenLite.to(grill_fire_mc, .5, {x:800, ease:Quad.easeOut});
			TweenLite.to(grill_mc, .5, {x:800, ease:Quad.easeOut});
			TweenLite.to(paperCover_mc, 2, {alpha:1, ease:Quad.easeIn});
			TweenLite.delayedCall(1, playPaperBurn);
			dropItemTimer.removeEventListener(TimerEvent.TIMER, dropItem);
			TweenLite.to(introCopy_mc, .5, {alpha:0, ease:Quad.easeOut});
			TweenLite.to(scorePanel_mc, .5, {alpha:0, ease:Quad.easeOut});
		}

		function playPaperBurn():void {
			paperCover_mc.play();
			TweenLite.to(bg_mc, 1, {alpha:0});
			TweenLite.delayedCall(2, fireOut);
		}
		
		function fireOut():void {
			grill_fire_mc.x = -100;
			grill_mc.x = -100;
			TweenLite.to(paperCover_mc, 1, {scaleX:2, scaleY:2, alpha:0, ease:Quad.easeIn, onComplete:resetGrill});
			grill_fire_mc.vectorFlames_mc.alpha = 1;
		}
		
		private function resetGrill():void {
			grill_mc.scaleX = grillScale;
			grill_fire_mc.scaleX = grillScale;
			TweenLite.delayedCall(2, grillFireOut);
			spinGrillWheels();
			grill_fire_mc.vectorFlames_mc.alpha = 0;
			grill_mc.vectorFlames_mc.alpha = 1;
			grill_mc.vectorFlames_mc.tagline_mc.alpha = 1;
			grill_fire_mc.scaleX = grill_fire_mc.scaleY = grill_mc.scaleX = grill_mc.scaleY = largeGrillScale;
			TweenLite.to(grill_fire_mc, .5, {x:115, ease:Quad.easeOut});
			TweenLite.to(grill_mc, .5, {x:115, ease:Quad.easeOut, onComplete:showPlayAgainButton});
		}
		
		private function showPlayAgainButton():void {
			play_again_btn.alpha = 0;
			play_again_btn.visible = true;
			TweenLite.to(play_again_btn, .5, {alpha:1, ease:Quad.easeOut});
		}
		
		private function grillFireOut():void {
			playBgFlame = false;
			TweenLite.to(grill_fire_mc, 5, {alpha:0, ease:Quad.easeOut});
		}
		
		private function gameKeyPressed(keyEvent:KeyboardEvent):void {
			if(keyEvent.keyCode == 37) {
				setInteractedMode();
				grillFacingLeft = true;
				moveGrill();
			} else 	if(keyEvent.keyCode == 39) {
				setInteractedMode();
				grillFacingLeft = false;
				moveGrill();
			}
		}
		
		public function setInteractedMode():void {
			if(autoGamePlay) {
				TweenLite.to(introCopy_mc, .2, {alpha:0, ease:Quad.easeOut});
				teaser_btn.visible = false;
				autoGamePlay = false;
			}
		}
		
		public function moveGrill():void {
			var newX;
			if(grillFacingLeft) {
				grill_mc.scaleX = -grillScale;
				grill_fire_mc.scaleX = -grillScale;
				newX = grill_mc.x - grillMovementIncrement;
				if(newX < 0 + halfGrillWidth) {
					newX = 0 + halfGrillWidth;
				}
			} else {
				grill_mc.scaleX = grillScale;
				grill_fire_mc.scaleX = grillScale;
				newX = grill_mc.x + grillMovementIncrement;
				if(newX > stageWidth - halfGrillWidth) {
					newX = stageWidth - halfGrillWidth;
				}
			}
			spinGrillWheels();
			TweenLite.to(grill_fire_mc, .5, {x:newX, ease:Quad.easeOut});
			TweenLite.to(grill_mc, .5, {x:newX, ease:Quad.easeOut});
		}
		
		private function getDistanceToMove(mc:MovieClip, edge:Number):Number {
			var presentPosition = mc.x + (mc.width/2);
			var distanceFromSide = edge - presentPosition;
			return distanceFromSide;
		}
		
		public function spinGrillWheels():void {
			TweenLite.to(fireGrillHub, 2, {rotation:WHEEL_SPIN_TIMES*360, ease:Quad.easeOut});
			TweenLite.to(grillHub, 2, {rotation:WHEEL_SPIN_TIMES*360, ease:Quad.easeOut});
		}
		
		private function openGrillMouth():void {
			if(gameOn) {
				TweenLite.to(fireGrillMouth, MOUTH_SPEED, {rotation:MOUTH_OPEN_POSITION, ease:Quad.easeOut});
				TweenLite.to(grillMouth, MOUTH_SPEED, {rotation:MOUTH_OPEN_POSITION, ease:Quad.easeOut, onComplete:shutGrillMouth});
			}
		}
		
		private function shutGrillMouth():void {
			TweenLite.to(fireGrillMouth, MOUTH_SPEED, {rotation:0, ease:Bounce.easeOut});
			TweenLite.to(grillMouth, MOUTH_SPEED, {rotation:0, ease:Bounce.easeOut, onComplete:openGrillMouth});
		}
		
		private function dropItem(evt:TimerEvent):void {
			if(gameOn) {
				var ranItem = Math.floor(Math.random() * MEAT_ARRAY.length);
				var classRef:Class = getDefinitionByName(MEAT_ARRAY[ranItem]) as Class;
				var meatItem = new classRef();
				var randomX = Math.random() * stageWidth;
				var randomSpeed = (Math.random() * (MEAT_MAX_DROP_SPEED_ARRAY[ranItem] - MIN_DROP_SPEED)) + MIN_DROP_SPEED;
				var targetY = stageHeight + meatItem.height;
				meatItem.pointValue = MEAT_ARRAY_VALUES[ranItem];
				meatItem.item = meatItem;
				meatItem.x = randomX;
				meatItem.y = -meatItem.height;
				meat_holder_mc.addChild(meatItem);
				meatItem.addEventListener(Event.ENTER_FRAME, hitGrill);
				TweenLite.to(meatItem, randomSpeed, {y:targetY, ease:Quad.easeIn, onComplete:removeThisListener, onCompleteParams:[meatItem]});
				if(gameOn) {
					dropItemTimer.delay = (Math.random()*(DROP_DELAY_INTERVAL_MAX - DROP_DELAY_INTERVAL_MIN))+DROP_DELAY_INTERVAL_MIN;
				}
			}
		}

		function hitGrill(evt:Event):void {
			if (evt.target.hitTestObject(grill_fire_mc)) {
				var scoreCallout = new MeatScore();
				if(evt.target.x < stageWidth/2){
					scoreCallout.x = grill_fire_mc.x + 40;
				} else{
					scoreCallout.x = grill_fire_mc.x - 80;
				}
				scoreCallout.y = evt.target.y - 10;
				var targetY = scoreCallout.y - 30;
				scoreCallout.txt_score.text = "+ " + evt.target.pointValue;
				addChild(scoreCallout);
				TweenLite.to(scoreCallout, 1, {y:targetY, alpha:0, ease:Quad.easeOut, onComplete:removeScoreCallout, onCompleteParams:[scoreCallout]});
				score += evt.target.pointValue;
				scorePanel_mc.txt_score.text = String(score);
				removeThisListener(evt.target);
				meat_holder_mc.removeChild(evt.target.item);
			}
		}
		
		function removeScoreCallout(mc:MovieClip) {
			removeChild(mc);
		}
		
		private function removeThisListener(targ):void {
			targ.removeEventListener(Event.ENTER_FRAME, hitGrill);
		}
		
		private function revGrill(evt:Event):void {
			spinGrillWheels();
			TweenLite.to(grill_fire_mc, .2, {alpha:1, ease:Quad.easeOut});
		}
		
		private function unRevGrill(evt:Event):void {
			if(!gameOn) {
				TweenLite.to(grill_fire_mc, .5, {alpha:0, ease:Quad.easeOut});
			}
		}
		
		private function updateFire(evt:Event):void {
			grillFire.update();
			if(playBgFlame) {
				bgFlame.update();
			}
		}
		
		private function mainRollOverEvent(evt:Event):void {
			cta_mc.gotoAndStop(2);
		}
		
		private function mainRollOutEvent(evt:Event):void {
			cta_mc.gotoAndStop(1);
		}
		
		private function teaserClickEvent(evt:Event):void {
			//trackAction('Click_From_AutoPlay');
			setInteractedMode();
		}
		
		private function mainClickEvent(evt:Event):void {
			var exitLink:String = root.loaderInfo.parameters.clickTag;
			if(!exitLink){
				exitLink = "http://www.valottery.com";
			}
			var tartgetWindow:String = root.loaderInfo.parameters.clickTARGET;
			if(!tartgetWindow){
				exitLink = "_blank";
			}
			var urlReq:URLRequest = new URLRequest(exitLink);
			var window:String = tartgetWindow;
			navigateToURL(urlReq, window);
		}
		
		private function legalRollOver(evt:Event):void {
			TweenLite.to(evt.target, .2, {y:55, ease:Quad.easeOut});
		}
		
		private function legalRollOut(evt:Event):void {
			TweenLite.to(evt.target, .2, {y:75, ease:Quad.easeOut});
		}
		
		private function trackAction(str:String):void {
			//trace('tracking: '+str);
			var trackFunction:String = root.loaderInfo.parameters.Measure_this;
			if(trackFunction){
				flash.external.ExternalInterface.call(trackFunction, str);
			}
		}
	}
}