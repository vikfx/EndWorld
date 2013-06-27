package 
{
	import com.greensock.events.TweenEvent;
	import com.greensock.easing.*;
	import com.greensock.TweenMax;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import flash.text.TextField;
	import flash.utils.getDefinitionByName;
	
	/**
	 * ...
	 * @author vik
	 */
	public class Game extends  MovieClip {
		
		private var _character :MovieClip
		private var _asteroidsContainer :MovieClip;
		private var _deadMsg :MovieClip;
		private var _blackScreen :MovieClip;
		private var _scoreTxt :TextField;
		private var _score :int;
		private var _direction :int;
		private var _currentTime :int;
		private var _deltaTime :int;
		private var _isWalking :Boolean;
		private const MAX_TIME :int = 90;
		private const ASTEROID_SPEED :Number = 8;
		private const CHARACTER_SPEED :Number = 3;
		private const ASTEROID_VALUE :int = 50;
		
		public function Game() {
		}
		
		public function init(evt :MouseEvent = null) :void {
			//direction
			_direction = 0;
			_isWalking = false;
			
			//time
			_currentTime = 0;
			_deltaTime = Math.round((0.3 + Math.random() * 0.7) * MAX_TIME);
			
			//score
			_score = 0;
			_scoreTxt = this.scoreTxt;
			_scoreTxt.visible = true;
			_scoreTxt.text = "SCORE : " + _score + " Pts";
			
			//asteroids
			_asteroidsContainer = this.asteroidsContainer;
			
			//character
			_character = this.character;
			_character.x = stage.stageWidth / 2;
			_character.visible = true;
			_character.gotoAndPlay("idle");
			stage.addEventListener(KeyboardEvent.KEY_DOWN, move);
			stage.addEventListener(KeyboardEvent.KEY_UP, stopMove);
			
			//message de fin
			_deadMsg = this.deadMsg;
			_deadMsg.y = -150;
			_blackScreen = this.black;
			_blackScreen.gotoAndStop(1);
			
			//update
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		//lancer un asteroid
		private function launchAsteroids() :void {
			//reinitialiser le temps du prochain asteroid
			_currentTime = 0;
			_deltaTime = Math.round((0.3 + Math.random() * 0.7) * MAX_TIME);
			
			//ajouter l'asteroid
			var asteroid :MovieClip = new Asteroid();
			asteroid.scaleX = asteroid.scaleY = 0.3 + (Math.random() * .7);
			_asteroidsContainer.addChild(asteroid);
			
			//deplacement de l'asteroid
			asteroid.x = Math.random() * stage.width;
			var fx :Number = Math.random() * stage.stageWidth;
			var dx :Number = fx - asteroid.x;
			var dy :Number = _character.y;
			asteroid.y = 0;
			asteroid.rotation = Math.atan2(dy, dx) * (180 / Math.PI) - 90;
			
			var duration :Number = 1 + (Math.random() * 10) / ASTEROID_SPEED;
			var tween :TweenMax = TweenMax.to(asteroid, duration, { x : fx, y : _character.y, ease :Linear.easeNone } );
			tween.addEventListener(TweenEvent.UPDATE, checkCollision);
			tween.addEventListener(TweenEvent.COMPLETE, destroyAsteroid);
		}
		
		//verifier la collision de l'asteroid avec le perso
		private function checkCollision(evt :TweenEvent) :void {
			var asteroid :MovieClip = (evt.target as TweenMax).target as MovieClip;
			
			if (asteroid.collider.hitTestObject(_character.collider)) {
				gameOver();
			}
		}
		
		private function destroyAsteroid(evt :TweenEvent) :void {
			//ajouter le score
			_score += ASTEROID_VALUE;
			_scoreTxt.text = "SCORE : " + _score + " Pts";
			
			//animer l'asteroid
			var asteroid :MovieClip = (evt.target as TweenMax).target as MovieClip;
			asteroid.rotation = 0;
			asteroid.gotoAndPlay("crash");
		}
		
		//deplacer le perso
		private function animCharacter() :void {
			if ((_character.x <= CHARACTER_SPEED + _character.width / 2 && _direction == -1) || (_character.x >= stage.stageWidth - _character.width / 2 - CHARACTER_SPEED && _direction == 1)) {
				return;
			}
			_character.x += CHARACTER_SPEED * _direction;
		}
		
		//game over
		private function gameOver() :void {
			trace("game over");
			
			//supprimer les asteroids et les tweens
			for (var i :int = 0; i < _asteroidsContainer.numChildren; i++) {
				var asteroid :MovieClip = _asteroidsContainer.getChildAt(i) as MovieClip;
				TweenMax.killTweensOf(asteroid);
				_asteroidsContainer.removeChild(asteroid);
			}
			
			//supprimer les evenements
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, move);
			stage.removeEventListener(KeyboardEvent.KEY_UP, stopMove);
			removeEventListener(Event.ENTER_FRAME, update);
			
			//masquer le perso et le score
			_character.visible = false;
			_scoreTxt.visible = false;
			
			//afficher le message de fin
			_deadMsg.scoreTxt.text = _scoreTxt.text;
			var tweenMsg :TweenMax = TweenMax.to(_deadMsg, 2, { y : 115 } );
			_blackScreen.gotoAndPlay(2);
			
			//ajouter l'action sur le btn rejouer
			_deadMsg.retry.addEventListener(MouseEvent.CLICK, init);
		}
		
		//animer le perso / direction du perso
		private function move(evt :KeyboardEvent) :void {
			//changer la direction
			switch(evt.keyCode) {
				case Keyboard.LEFT :
					_direction = -1;
					break;
				case Keyboard.RIGHT :
					_direction = 1;
					break;
				default :
					return;
			}
			
			//animer le perso
			if (!_isWalking) {
				_isWalking = true;
				_character.gotoAndPlay("walk");
			}
			
			_character.scaleX = -_direction;
		}
		
		//animer le perso / direction du perso
		private function stopMove(evt :KeyboardEvent) :void {
			//changer la direction
			_direction = 0;
			
			//animer le perso
			_character.gotoAndPlay("idle");
			_isWalking = false;
		}
		
		//actualiserr la scene
		private function update(evt :Event) :void {
			//animer le perso
			animCharacter();
			
			//ajouter des asteroids
			_currentTime ++;
			if (_currentTime >= _deltaTime) {
				launchAsteroids();
			}
		}
	}
	
}