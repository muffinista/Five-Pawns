package com.muffinlabs {
  import flash.geom.Point;
  import de.polygonal.ds.Array2;

  public final class Move {
	private var _board:Board;
	private var _player:int;
	private var _start:Point;
	private var _stop:Point;

	public function Move(board:Board, player:int, start:Point, stop:Point) {
	  _board = board;
	  _start = start;
	  _stop = stop;
	  _player = player;
	} // Move

	public function get start():Point {
	  return _start;
	}
	public function get dest():Point {
	  return _stop;
	}
	public function get player():int {
	  return _player;
	}

	public function get result():Board {
	  var _tmp:Array2 = copy(_board.state);
	  _tmp.set(_start.x, _start.y, 0);
	  _tmp.set(_stop.x, _stop.y, _player);

	  return new Board(_tmp, _board.currentRound + 1);
	}


	public function copy(src:Array2):Array2 {
	  var maxX:int = src.width;
	  var maxY:int = src.height;
	  var _dest:Array2 = new Array2(maxX, maxY);


	  for ( var x:int = 0; x < maxX; x++ ) {
		for ( var y:int = 0; y < maxY; y++ ) {
		  _dest.set(x, y, src.get(x, y));
		}
	  }
	  return _dest;
	}

	public function toString():String {
	  return "player: " + _player + " from " + _start + " to " + _stop;
	}
  }
}