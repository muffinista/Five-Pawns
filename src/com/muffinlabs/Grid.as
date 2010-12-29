package com.muffinlabs {
  import flash.display.*;
	
  /**
   * ...
   * @author Default
   */
  public class Grid extends Sprite {
	public function draw(sprite:Sprite, width:uint, height:uint, spacingX:uint, spacingY:uint):void {
	  var tmpx:int = 0;
	  var tmpy:int = 0;
	  var grid:Shape = new Shape();    

	  grid.graphics.lineStyle(1, 0xFF0000, 1, false, LineScaleMode.VERTICAL,
							  CapsStyle.NONE, JointStyle.MITER, 10);

	  for ( tmpx = 0; tmpx <= width; tmpx += spacingX) {
		//trace(tmpx + " " + 0);
		grid.graphics.moveTo(tmpx, 0);
		grid.graphics.lineTo(tmpx, height);
	  }

	  for ( tmpy = 0; tmpy <= height; tmpy += spacingY) {
		//trace(0 + " " + tmpy);
		grid.graphics.moveTo(0, tmpy);
		grid.graphics.lineTo(width, tmpy);
	  }

	  sprite.addChild(grid);
	}

	public function Grid() {
			
	}
		
  }
	
}