package com.muffinlabs {

  import de.polygonal.ds.Array2;
  import com.muffinlabs.*;
  import flash.geom.Point;

  public final class Board {
	public static const HUMAN:int = 1;
	public static const COMPUTER:int = 2;

	private var _data:Array2;
	private var lastMove:Move = null;
	public var currentRound:int = 1;

	public static var MAX_DEPTH:int = 12;
	public static var MAX_ROUND_RECORD:int = 10;
	public static var CURRENT_DEPTH:int = MAX_DEPTH;

	public static const NO_SCORE_YET:int = -10000000;
	public static const PLAYER_WINS:int = 10;
	public static const OTHER_PLAYER_WINS:int = -10;

	public static var WIDTH:int = 4;
	public static var HEIGHT:int = 4;

	/**
	 * constructor
	 */
	public function Board(b:Array2=null,r:int=1) {
	  if ( b == null ) {
		_data = new Array2(WIDTH, HEIGHT);

		// set the entire array to zero
		_data.fill(0);

		for ( var x:int = 0; x < WIDTH; x++ ) {
		  // 1 == player
		  _data.set(x, 0, COMPUTER);

		  // 2 == other player
		  _data.set(x, HEIGHT-1, HUMAN);
		}
	  }
	  else {
		_data = b;
	  }
	  currentRound = r;
	} // Board


	public static function get width():int {
	  return WIDTH;
	}
	public static function get height():int {
	  return HEIGHT;
	}
	public static function set width(x:int):void {
	  WIDTH = x;
	}
	public static function set height(x:int):void {
	  HEIGHT = x;
	}

	/**
	 * set the depth the AI will search for a best move.  Effectively sets
	 * the challenge level
	 */
	public static function set level(l:int):void {
	  if ( l <= MAX_DEPTH && l > 1 ) {
		CURRENT_DEPTH = l;
	  }
	}

	public static function get level():int {
	  return CURRENT_DEPTH;
	}


	/**
	 * figure out who has the current move.  we track the last play,
	 * the current move will be whichever player didn't make that move
	 */
	public function get currentPlayer():int {
	  if ( lastMove == null || lastMove.player == COMPUTER ) {
		return HUMAN;
	  }
	  return COMPUTER;
	}

	public function get state():Array2 {
	  return _data;
	}
	public function set state(x:Array2):void {
	  _data = x;
	}

	public function at(x:int, y:int):int {
	  return _data.get(x, y);
	}

	public function apply(m:Move):void {
	  lastMove = m;
	  _data = m.result.state;
	  currentRound++;
	}


	public function getBestMove():Move {
	  var bestMove:Move = null;
	  var bestScore:int = 1000000;

	  //
	  // go through each potential move at this point and figure out which one makes
	  // the most sense
	  //
	  var moves:Array = getMoves(COMPUTER);

	  for each ( var m:Move in moves ) {
		  var tmpScore:int = m.result.minimax(HUMAN, Board.CURRENT_DEPTH);

		  if ( m.result.isWinner(COMPUTER) ) {
			return m;
		  }

		  if ( bestMove == null || 
			   tmpScore < bestScore ||
			   // if we have two equal moves, pick at random
			   (tmpScore == bestScore && Math.random() >= 0.5) ) {
			bestScore = tmpScore;
			bestMove = m;
		  }
		}
	  return bestMove;
	}


	private function recordValue(key:String, val:int):void {
	  if ( currentRound <= MAX_ROUND_RECORD ) {
		//trace("* " + key+":"+val);
	  }

	  // always store the result
	  Scores.table[key] = val;
	}

	/**
	 * @see http://en.wikipedia.org/wiki/Minimax
	 * function minimax(node, depth)
	 * if node is a terminal node or depth == 0:
     *   return the heuristic value of node
	 * else:
     *   α = -∞
     *   for child in node:                       # evaluation is identical for both players 
     *       α = max(α, -minimax(child, depth-1))
     *   return α
	 */
	private function minimax(player:int, depth:int):int {
	  var tmpID:String = id;
	  if ( player == COMPUTER && 
		   Scores.table != null && Scores.table[tmpID] != null ) {
		return Scores.table[tmpID];
	  }

	  var otherPlayer:int = player == HUMAN ? COMPUTER : HUMAN;

	  if ( depth == 0 ) {
		var tmpResult:int = score(player);
		if ( player == COMPUTER ) {
		  recordValue(tmpID, tmpResult);
		}
		return tmpResult;
	  }
	  if ( isWinner(otherPlayer) ) {
		if ( player == COMPUTER ) {
		  recordValue(tmpID, OTHER_PLAYER_WINS);
		}
		return OTHER_PLAYER_WINS;
	  }
	  if ( isWinner(player) ) {
		if ( player == COMPUTER ) {
		  recordValue(tmpID, PLAYER_WINS);
		}
		return PLAYER_WINS;
	  }
	  

	  var tmpScore:int = NO_SCORE_YET;
	  var tmpMoves:Array = getMoves(player);

	  if ( tmpMoves.size == 0 ) {
		tmpScore = OTHER_PLAYER_WINS;
	  }
	  else {
		for each ( var m:Move in tmpMoves ) {
			var tmpBoard:Board = m.result;
			var otherScore:int = -1 * tmpBoard.minimax(otherPlayer, depth - 1);

			if ( tmpScore == NO_SCORE_YET || otherScore > tmpScore ) {
			  tmpScore = otherScore;
			}
		  }
	  }

	  if ( player == COMPUTER ) {
		recordValue(tmpID, tmpScore);
	  }
	  return tmpScore;
	}

	/**
	 * return a string that uniquely identifies this board instance
	 */ 
	public function get id():String {
	  var mult:uint = 1;
	  var p1:uint = 0;
	  var p2:uint = 0;

	  for ( var x:int = 0; x < WIDTH; x++ ) {
		for ( var y:int = 0; y < HEIGHT; y++ ) {
		  if ( _data.get(x, y) == HUMAN ) {
			// Set a bit (where n is the bit number, and 0 is the least significant bit):
			// unsigned char a |= (1 << n);
			p1 |= 1 << mult;
		  }
		  else if ( _data.get(x, y) == COMPUTER ) {
			p2 |= 1 << mult;
		  }

		  mult++;
		}
	  }

	  return p1.toString(36) + "-" + p2.toString(36);  
	}

	/**
	 * get a list of pieces for the specified player
	 */
	public function getPieces(player:int):Array {
	  var tmp:Array = [];

	  for ( var x:int = 0; x < WIDTH; x++ ) {
		for ( var y:int = 0; y < HEIGHT; y++ ) {
		  if ( _data.get(x, y) == player ) {
			tmp.push(new Point(x, y));
		  }
		}
	  }

	  return tmp;

	}

	/**
	 * return a list of moves for the specified player
	 */
	public function getMoves(player:int):Array {
	  var moves:Array = [];
	  var otherPlayer:int = player == HUMAN ? COMPUTER : HUMAN;
	  var pieces:Array = getPieces(player);

	  for each ( var p:Point in pieces ) {
		  moves = moves.concat(movesForPiece(p));
		}
	  return moves;
	}

	public function isWinner(player:int):Boolean {
	  var otherPlayer:int = player == HUMAN ? COMPUTER : HUMAN;
	  var rowIndex:int = player == HUMAN ? 0 : HEIGHT - 1;

	  var pieces:Array = getPieces(player);
	  for each ( var p:Point in pieces ) {
		  if ( p.y == rowIndex ) {
			return true;
		  }
		} // foreach

	  if ( getPieces(otherPlayer).length == 0 || getMoves(otherPlayer).length == 0 ) {
		return true;
	  }

	  return false;
	}

	public function isValidMove(p1:Point, p2:Point):Boolean {
	  for each ( var m:Move in movesForPiece(p1) ) {
		  //trace(m.dest.x + " == " + p2.x + " && " + m.dest.y + " == " + p2.y);
		  if ( m.dest.x == p2.x && m.dest.y == p2.y ) {
			return true;
		  }
		}	  
	  return false;
	}

	private function centerPiece(x:int, y:int):Boolean {
	  if ( width % 2 == 0 ) {
		return false;
	  }

	  return ( x == (width - 1)/2 && y == (height - 1)/2 );
	}

	/**
	 * return a list of moves for the specified piece
	 */
	public function movesForPiece(p:Point):Array {
	  var player:int = _data.get(p.x, p.y);
	  var potentialMoves:Array = [];

	  var otherPlayer:int;
	  var rowIndex:int;

	  if ( player == HUMAN ) {
		otherPlayer = COMPUTER;
		rowIndex = p.y - 1;
	  }
	  else {
		otherPlayer = HUMAN;
		rowIndex = p.y + 1;
	  }


	  // possible forward move
	  //&& ! centerPiece(p.x, rowIndex)
	  if ( _data.get(p.x, rowIndex) == 0  ) {
		potentialMoves.push(new Move(this, player, p, new Point(p.x, rowIndex)));
	  }

	  var rightEdge:int = width - 1;

	  // edge pieces moving diagonally inward
	  if ( p.x == 0 && _data.get(1, rowIndex) == otherPlayer ) {
		potentialMoves.push( new Move(this, player, p, new Point(1, rowIndex) ));
	  }
	  else if ( p.x == rightEdge && _data.get(rightEdge - 1, rowIndex) == otherPlayer ) {
		potentialMoves.push( new Move(this, player, p, new Point(rightEdge - 1, rowIndex) ));
	  }

	  // center piece moving diagonally inward or outward
	  else if ( p.x > 0 && p.x < width-1 ) {
		var tmpX:int = p.x - 1;
		if ( _data.get(tmpX, rowIndex) == otherPlayer ) {
		  potentialMoves.push( new Move(this, player, p, new Point(tmpX, rowIndex) ));
		}
	
		tmpX = p.x + 1;
		if ( _data.get(tmpX, rowIndex) == otherPlayer ) {
		  potentialMoves.push( new Move(this, player, p, new Point(tmpX, rowIndex) ));
		}
	  }

	  //	  trace(potentialMoves);
	  return potentialMoves;
	}


	public function canBeCaptured(p:Point):Boolean {
	  var player:int = _data.get(p.x, p.y);
	  var otherPlayer:int;
	  var rowIndex:int;

	  if ( player == HUMAN ) {
		otherPlayer = COMPUTER;
		rowIndex = p.y - 1;
	  }
	  else {
		otherPlayer = HUMAN;
		rowIndex = p.y + 1;
	  }

	  var rightEdge:int = width - 1;

	  // edge pieces moving diagonally inward
	  if (
		  ( p.x == 0 && _data.get(1, rowIndex) == otherPlayer ) ||
		  ( p.x == rightEdge && _data.get(rightEdge - 1, rowIndex) == otherPlayer )
		  ) {
		return true;
	  }

	  // center piece moving diagonally inward or outward
	  if ( p.x > 0 && p.x < width-1 ) {
		var tmpX:int = p.x - 1;
		if (
			( _data.get(tmpX, rowIndex) == otherPlayer ) ||
			( _data.get(tmpX, rowIndex) == otherPlayer ) )
		  {
			return true;
		  }
	  }

	  return false;
	}

	/**
	 * calculate the value of this board for the specified player.
	 * this is the value of the board for the player minus the value for the other player
	 */
	public function score(player:int):int {
	  return getMoves(player).length;
	}


	public function toString():String {
	  var result:String = "\n====\n";

	  for ( var y:int = 0; y < HEIGHT; y++ ) {
		for ( var x:int = 0; x < WIDTH; x++ ) {
		  var tmp:int = _data.get(x, y);
		  if ( tmp == 0 ) {
			result = result + ".";
		  }
		  else {
			result = result + tmp;
		  }
		}
		result = result + "\n";
	  }

	  return result;
	  
	}

  }
}