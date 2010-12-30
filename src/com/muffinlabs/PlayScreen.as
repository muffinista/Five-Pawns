package com.muffinlabs {
  import com.muffinlabs.*;
  import caurina.transitions.Tweener;

  import flash.display.Sprite;
  import flash.events.*;
  import flash.display.*;
  import flash.geom.*;
  import flash.utils.Timer;
  import flash.text.*;

  import com.google.analytics.GATracker;
  import com.google.analytics.AnalyticsTracker;

  import flash.net.URLRequest;
  import flash.net.navigateToURL;

  /**
   * display/manage the main screen of the game -- the board/etc
   */
  public class PlayScreen extends Sprite implements IGameScene {
	public static const PRE_GAME:uint      = 2;
	public static const HUMAN_TURN:uint    = 3;
	public static const HUMAN_MOVING:uint   = 5;
	public static const HUMAN_MOVED:uint   = 6;
	public static const COMPUTER_TURN:uint = 7;
	public static const COMPUTER_MOVING:uint = 8;
	public static const GAME_OVER:uint     = 9;
	public static const GAME_ENDED:uint     = 10;

	public static const ANIMATION_SPEED:Number = 0.4;

	// w/h of an image
	public static const BLOCK_SIZE:uint = 80;

	private var _winner:uint;
	private var _board:Board;
	private var _first_player:uint = Board.HUMAN;
	private var _state:uint = HUMAN_TURN;

	// vars for tracking the start/end of a move
	private var moveStart:Point = null;
	private var moveEnd:Point = null;

	// we'll use a timer to update game state
	private var timer:Timer;

	// sprites/display elements
	private var picker:Sprite = null;
	private var background:Sprite;
	private var pieceDisplay:Sprite;
	private var overlay:Sprite;

	private var gameTitle:TextWidget;
	private var footerButton:SpriteButton;
	private var currentScore:TextWidget;

	private var currentTurn:TextField;
	private var winnerDisplay:TextWidget;


	private var restartButton:SpriteButton;
	private var backButton:SpriteButton;

	private var boardX:uint = 40;
	private var boardY:uint = 40;

	public static var boardBack:Class = null;

	[Embed(source="../../../assets/back-off.png")]
	  private var backOff:Class;
	[Embed(source="../../../assets/back-over.png")]
	  private var backOn:Class;
	[Embed(source="../../../assets/reload-off.png")]
	  private var restartOff:Class;
	[Embed(source="../../../assets/reload-over.png")]
	  private var restartOn:Class;

	[Embed(source="../../../assets/white.png")]
	  private var potentialMoveTile:Class;
	[Embed(source="../../../assets/red.png")]
	  private var playerTile:Class;
	[Embed(source="../../../assets/green.png")]
	  private var computerTile:Class;

	[Embed(source="../../../assets/yellow.png")]
	  private var playerActiveTile:Class;
	[Embed(source="../../../assets/yellow.png")]
	  private var computerActiveTile:Class;


	public function PlayScreen() {
	  timer = new Timer(250);
	  timer.addEventListener(TimerEvent.TIMER, updateGameState);

	  restartButton = new SpriteButton(new restartOff(), new restartOn());
	  backButton = new SpriteButton(new backOff(), new backOn());
	  
	  // draw a background on -- note that this is actually needed
	  // to get mouse_move events working
	  graphics.beginFill(0x000000);
	  graphics.drawRect(0, 0, (Board.width * BLOCK_SIZE) + 80, (Board.height*BLOCK_SIZE) + 120);
	  graphics.endFill();

	  _board = new Board();

	  background = new Sprite();
	  background.x = boardX;
	  background.y = boardY;

	  var tmpBack:* = new boardBack();
	  background.addChild(tmpBack);
	  tmpBack.x = 0;
	  tmpBack.y = 0;

	  //	  var g:Grid = new Grid();
	  //	  g.draw(background, BLOCK_SIZE*Board.width, BLOCK_SIZE*Board.height, BLOCK_SIZE, BLOCK_SIZE);
	  addChild(background);

	  pieceDisplay = new Sprite();
	  pieceDisplay.x = boardX;
	  pieceDisplay.y = boardY;
	  addChild(pieceDisplay);

	  /**
	   * this is a little hackish.  draw an overlay over the board,
	   * which will receive mouse events, and then figure out where
	   * on the board the user is pointing.  i can't get this to work
	   * without actually drawing something at the moment.
	   */
	  overlay = new Sprite();
	  overlay.graphics.beginFill(0x000000, 0);
	  overlay.graphics.drawRect(0, 0, (BLOCK_SIZE+1)*Board.width, (BLOCK_SIZE+1)*Board.height);
	  overlay.graphics.endFill();

	  overlay.x = boardX;
	  overlay.y = boardY;
	  addChild(overlay);

	  //
	  // generate a sprite we'll show when picking user's tile, but don't
	  // show it on the screen yet
	  //
	  picker = new Sprite();
		   
	  var tmpPiece:* = new playerActiveTile();
	  picker.addChild(tmpPiece);

	  overlay.addChild(picker);

	  var bottomY:uint = height;

	  backButton.x = boardX;
	  backButton.y = bottomY - 57;
	  backButton.addEventListener("click", onBack);
	  addChild(backButton); 
	  
	  restartButton.x = boardX + 28;
	  restartButton.y = bottomY - 60;
	  restartButton.addEventListener("click", onRestart);
	  addChild(restartButton); 


	  currentScore = new TextWidget(currentScoreText(), 0xaaaaaa, "abstract", 14);
	  currentScore.x = boardX + 55;
	  currentScore.y = bottomY - 60;
	  addChild(currentScore);


	  currentTurn = new TextField();
	  currentTurn.textColor = 0xff0000;
	  currentTurn.selectable = false;
	  currentTurn.autoSize = TextFieldAutoSize.RIGHT;

	  if ( Board.width == 4 ) {
		currentTurn.x = boardX + 320;
	  }
	  else {
		currentTurn.x = boardX + 400;
	  }
	  currentTurn.y = bottomY - 60;
	  addChild(currentTurn); 

	  var _format:TextFormat = new TextFormat();
	  _format.color = 0xff0000;
	  _format.size = 18;
	  _format.font = "abstract";
	  currentTurn.embedFonts = true;
	  currentTurn.defaultTextFormat = _format;
	  currentTurn.setTextFormat(_format);

	  overlay.addEventListener(MouseEvent.MOUSE_MOVE, checkActiveBlock);
	  overlay.addEventListener(MouseEvent.MOUSE_UP, checkActiveBlock);
	  overlay.addEventListener(MouseEvent.MOUSE_DOWN, checkActiveBlock);

	  winnerDisplay = new TextWidget("abcdefghijklmon", 0xff0000, "abstract");
	  addChild(winnerDisplay);
	  winnerDisplay.x = -1000;

	  if ( Board.width == 4 ) {
		gameTitle = new TextWidget("Four Pawns", 0xaaaaaa, "abstract", 20);
	  }
	  else {
		gameTitle = new TextWidget("Five Pawns", 0xaaaaaa, "abstract", 20);
	  }

	  gameTitle.x = 40;
	  gameTitle.y = 10;
	  addChild(gameTitle);


	  footerButton = new SpriteButton(
									  new TextWidget("muffinlabs.com", 0xaaaaaa, "abstract", 14),
									  new TextWidget("muffinlabs.com", 0xff0000, "abstract", 14));


	  footerButton.addEventListener("click", onHyperLinkEvent);

	  if ( Board.width == 4 ) {
		footerButton.x = boardX + 200;
	  }
	  else {
		footerButton.x = boardX + 280;
	  }

	  footerButton.y = 15;
	  addChild(footerButton);

	}

	private function currentScoreText():String {
	  return "Score: " + Scores.wins + " - " + Scores.losses;
	}

	public function restart():void {
	  moveStart = null;
	  moveEnd = null;

	  _board = new Board();
	  redraw();


	  currentTurn.text = _first_player == Board.HUMAN ? "Your Turn" : "My Turn";
	  currentTurn.alpha = 100;
	  //	  backButton.alpha = 100;
	  pieceDisplay.alpha = 100;
	  background.alpha = 100;

	  backButton.x = boardX;
	  restartButton.x = boardX + 30;


	  Tweener.addTween(this, { _autoAlpha:1, time:0.3, transition:"linear",
			onComplete:function():void {
			startFirstMove();
		  }
		});
	}

	private function startFirstMove():void {
	  if ( _first_player == Board.HUMAN ) {
		_state = HUMAN_TURN;
	  }
	  else {
		_state = COMPUTER_TURN;
	  }
	  updateCurrentPlayerDisplay(true);
	}

	public function load():void {
	  timer.start();
	  redraw();
	  startFirstMove();
	}

	public function update():void {

	}

	public function redraw():void {
	  drawBoard();
	  picker.x = -1000;
	  winnerDisplay.x = -1000;

	  currentScore.text = currentScoreText();
	}

	public function unload():void {

	}

	/**
	 * depending on the current state of the game, see
	 * if there's any work to be done.
	 */
	private function updateGameState(e:Event=null):void {
	  switch(_state) {

		// user decided to start playing, init the game
	  case PRE_GAME:
		_state = HUMAN_TURN;
		break;

	  case HUMAN_TURN:
		if ( _board.isWinner(Board.HUMAN) ) {
		  _state = GAME_OVER;
		  _winner = Board.HUMAN;
		}
		break;
	  case HUMAN_MOVED:
		picker.x = -1000;
		_state = HUMAN_MOVING;

		var m:Move = new Move(_board, Board.HUMAN, moveStart, moveEnd);
		_board.apply(m);

		moveStart = null;
		moveEnd = null;

		animateMove(m, updateAfterHumanMove);
		break;
	  case COMPUTER_TURN:
		var m2:Move = _board.getBestMove();

		if ( m2 == null ) {
		  _state = GAME_OVER;
		  _winner = Board.HUMAN;
		  return;
		}

		_board.apply(m2);
		_state = COMPUTER_MOVING;

		animateMove(m2, updateAfterComputerMove);
		break;
	  case COMPUTER_MOVING:
		break;
	  case GAME_OVER:
		displayGameOver();
		break;
	  case GAME_ENDED:
		break;
	  } // switch

	} // updateGameState

	private function updateAfterHumanMove():void {
	  drawBoard();
		
	  if ( _board.isWinner(Board.HUMAN) ) {
		_winner = Board.HUMAN;
		_state = GAME_OVER;
	  }
	  else {
		_state = COMPUTER_TURN;
		updateCurrentPlayerDisplay();	  
	  }
	}

	private function updateAfterComputerMove():void {
	  drawBoard();
			
	  if ( _board.isWinner(Board.COMPUTER) ) {
		_state = GAME_OVER;
		_winner = Board.COMPUTER;
	  }
	  else {
		_state = HUMAN_TURN;
		updateCurrentPlayerDisplay();
	  }
	}

	/**
	 * the game is over - figure out who won and display a message
	 */
	private function displayGameOver():void {
	  _state = GAME_ENDED;
	  currentTurn.alpha = 0;
	  restartButton.x = -1000;
	  backButton.x = -1000;

	  var tmpText:String = _winner == Board.HUMAN ? "You Win!" : "You Lose";

	  var _tracker:AnalyticsTracker;
	  _tracker = new GATracker(this, "UA-XXXXX-XX", "AS3", false );

	  var game:String = Board.width == 4 ? "fourpawns" : "fivepawns";
	  if ( _winner == Board.HUMAN ) {
		_tracker.trackEvent("Games", game, "win");
		Scores.wins++;
	  }
	  else {
		_tracker.trackEvent("Games", game, "lose");
		Scores.losses++;
	  }
	  

	  winnerDisplay.text = tmpText;
	  winnerDisplay.size = 48;

	  winnerDisplay.x = ((Board.width * BLOCK_SIZE) + 80 - winnerDisplay.width) / 2;
	  winnerDisplay.y = ((Board.height*BLOCK_SIZE) + 120 - winnerDisplay.height) / 2;
	  winnerDisplay.alpha = 0;

	  Tweener.addTween(pieceDisplay, { _autoAlpha:0.2, time:0.5, transition:"linear"} );
	  Tweener.addTween(background, { _autoAlpha:0.2, time:0.5, transition:"linear"} );
	  Tweener.addTween(winnerDisplay, { _autoAlpha:1, time:0.5, transition:"linear", onComplete:endGame} );
	}

	private function onRestartClick(evt:MouseEvent):void {
	  removeEventListener(MouseEvent.MOUSE_UP, onRestartClick);

	  Tweener.addTween(this, { _autoAlpha:0, time:0.1, transition:"linear",
			onComplete:function():void { restart();  }
		});
	}

	/**
	 * game is over, when the user clicks we'll restart
	 */
	private function endGame():void {
	  //
	  // update who goes first
	  //
	  if ( _first_player == Board.COMPUTER ) {
		_first_player = Board.HUMAN;
	  }
	  else {
		_first_player = Board.COMPUTER;
	  }

	  addEventListener(MouseEvent.MOUSE_UP, onRestartClick);
	} // endGame

	private function onRestart(evt:MouseEvent):void {
	  Tweener.addTween(this, { _autoAlpha:0, time:0.3, transition:"linear",
			onComplete:function():void {
			restart();
		  }
		});
	} // endGame

	private function onBack(evt:MouseEvent):void {
	  var endScene:MenuScreen = new MenuScreen();
	  GameSceneManager.changeScene(endScene);
	}

	/**
	 * when the user moves the mouse around, we'll highlight
	 * the start/end points of any potential moves they want to make
	 */
	private function checkActiveBlock(evt:MouseEvent):void {
	  if ( _state != HUMAN_TURN ) {
		evt.stopPropagation();
		return;
	  }


	  var spriteDest:Point = evt.currentTarget.globalToLocal(new Point(evt.stageX, evt.stageY));
	  var x:uint = spriteDest.x / BLOCK_SIZE;
	  var y:uint = spriteDest.y / BLOCK_SIZE;

	  switch(evt.type) {
		//	  case MouseEvent.MOUSE_DOWN:
		//		pickActivePiece(boardX, boardY);
		//		break;
	  case MouseEvent.MOUSE_UP:
		if ( x >= Board.width || y >= Board.height ) {
		  return;
		}

		if ( moveStart == null ) {
		  if ( _board.at(x, y) == Board.HUMAN ) {
			moveStart = new Point(x, y);
			drawPotentialMoves();
		  }
		  else {
			moveStart = null;
		  }
		}
		else if( _board.isValidMove(moveStart, new Point(x, y))) {
		  moveEnd = new Point(x, y);
		}
		else {
		  cancelMove();
		}


		if ( moveStart != null ) {
		  var tmpEnd:Point = new Point(x, y);
		  if ( checkMove(tmpEnd) ) {
			_state = HUMAN_MOVED;
		  }
		  //		  else if ( tmpEnd.x != moveStart.x && tmpEnd.y != moveStart.y ) {
		  //			cancelMove();
		  //		  }
		}
		break;
	  case MouseEvent.MOUSE_MOVE:
		highlightActivePiece(x, y);
		break;
	  } // switch
	}

	/**
	 * check to see if a move to the given point is valid
	 */
	private function checkMove(moveEnd:Point):Boolean {
	  return _board.isValidMove(moveStart, moveEnd);
	}

	private function cancelMove():void {
	  moveStart = null;
	  picker.x = -1000;
	  drawBoard();
	}


	private function updateCurrentPlayerDisplay(animate:Boolean=true):void {
	  var playerText:String = _state == HUMAN_TURN ? "Your Turn" : "My Turn";
	  currentTurn.text = playerText;
	  currentTurn.alpha = 0;
	  Tweener.addTween(currentTurn, { _autoAlpha:1.0, time:0.25, transition:"linear"} );
	}



	private function animateMove(m:Move, callback:Function = null):void {
	  var prefix:String = m.player == Board.HUMAN ? "human-" : "computer-";

	  var potentialMoves:DisplayObject = pieceDisplay.getChildByName("potential-moves");
	  if ( potentialMoves != null ) {
		pieceDisplay.removeChild(potentialMoves);
	  }

	  var tmpPiece:String = prefix + m.start.x + "-" + m.start.y;
	  var piece:DisplayObject = pieceDisplay.getChildByName(tmpPiece);
	  var destX:uint = m.dest.x * BLOCK_SIZE;
	  var destY:uint = m.dest.y * BLOCK_SIZE;

	  piece.name = prefix + m.dest.x + "-" + m.dest.y;

	  Tweener.addTween(piece, 
					   {
						 x : destX,
						   y : destY,
						   time : PlayScreen.ANIMATION_SPEED,
						   transition:"linear",
						   onComplete : callback
						   }
					   );
	}


	private function drawBoard():void {
	  clearBoard();
	  for ( var x:uint = 0; x < Board.width; x++ ) {
		for ( var y:uint = 0; y < Board.height; y++ ) {
		  var tmpPiece:*;
		  if ( _board.state.get(x, y) == Board.HUMAN ) {
			tmpPiece = new playerTile();
			tmpPiece.name = "human-" + x + "-" + y;
			drawPiece(tmpPiece, x, y);
		  }
		  else if ( _board.state.get(x, y) == Board.COMPUTER ) {
			tmpPiece = new computerTile();
			tmpPiece.name = "computer-" + x + "-" + y;
			drawPiece(tmpPiece, x, y);
		  }
		}
	  }
	}

	private function drawPiece(tmpPiece:DisplayObject, x:uint, y:uint):void {
	  tmpPiece.x = x * BLOCK_SIZE;
	  tmpPiece.y = y * BLOCK_SIZE;
	  pieceDisplay.addChild(tmpPiece);
	}

	private function clearBoard():void {
	  if ( pieceDisplay != null ) {
		while(pieceDisplay.numChildren) {
		  pieceDisplay.removeChildAt(0);
		}
	  }
	}

	private function highlightActivePiece(x:uint, y:uint):void {
	  if ( moveStart != null ) {
		if ( _board.isValidMove(moveStart, new Point(x, y)) ) { 
		  picker.x = x * BLOCK_SIZE;
		  picker.y = y * BLOCK_SIZE;
		}
	  }
	  else if ( x < Board.width && y < Board.height &&
				_board.at(x, y) == Board.HUMAN ) { 
		picker.x = x * BLOCK_SIZE;
		picker.y = y * BLOCK_SIZE;
	  }
	  else if ( picker != null ) {
		picker.x = -1000;
	  }
	}


	/**
	 * display the potential moves the currently selected piece can make
	 */
	private function drawPotentialMoves():void {
	  var tmpX:uint = 0;
	  var tmpY:uint = 0;

	  var tmp:Sprite = new Sprite();
	  tmp.name = "potential-moves";
	  tmp.x = 0;
	  tmp.y = 0;

	  for each ( var m:Move in _board.movesForPiece(moveStart) ) {
		  tmpX = m.dest.x * BLOCK_SIZE;
		  tmpY = m.dest.y * BLOCK_SIZE;

		  var tmpPiece:* = new potentialMoveTile();
		  tmpPiece.x = tmpX;
		  tmpPiece.y = tmpY;
		  tmpPiece.alpha = 0.65;
		  tmp.addChild(tmpPiece);
	  } // foreach

	  pieceDisplay.addChild(tmp);

	}

	private function pickActivePiece(x:uint, y:uint):void {
	  if ( x >= Board.width || y >= Board.height ) {
		return;
	  }

	  if ( moveStart == null ) {
		if ( _board.at(x, y) == Board.HUMAN ) {
		  moveStart = new Point(x, y);
		  drawPotentialMoves();
		}
		else {
		  moveStart = null;
		}
	  }
	  else if( _board.isValidMove(moveStart, new Point(x, y))) {
		moveEnd = new Point(x, y);
	  }
	} // pickActivePiece

	private function onHyperLinkEvent(evt:Event):void {
	  navigateToURL(new URLRequest("http://muffinlabs.com/"), "_new");
	}
	
	
  } // PlayScreen
}
