// **********************************
//
// © 2009 - James McNess
// http://www.codeandvisual.com
//
// **********************************

package com.muffinlabs {
  //
  // *******************************************************************
  //
  //
  // IMPORTS
  //
  //
  // *******************************************************************
  import flash.display.*;
  import flash.events.*;
  import flash.utils.*;
  public class Background{
	//
	// *******************************************************************
	//
	//
	// PROPERTIES
	//
	//
	// *******************************************************************
	private var pFrameMonitor:DisplayObject;
	private var pCPURatio:Number;

	//
	private var pIdleLength:Number;
	private var pFunctions:Array;
	//
	//
	// *******************************************************************
	//
	//
	// INITIALISATION
	//
	//
	// *******************************************************************
	public function Background(thisFrameMonitor:DisplayObject, thisCPURatio:Number) {
	  pFrameMonitor = thisFrameMonitor;
	  pCPURatio = thisCPURatio;
	  init();
	}
	private function init():void {
	  pFunctions = new Array();
	  pIdleLength = 1000/pFrameMonitor.stage.frameRate*pCPURatio;
	  pFrameMonitor.addEventListener(Event.ENTER_FRAME,doIdle);
	}

	private function doIdle(evt:Event):void {
	  var myStartTime:Number = getTimer();
	  while(getTimer()-myStartTime<pIdleLength&&pFunctions.length>0){
		for(var i:Object in pFunctions){
		  var myFunction:Function = pFunctions[i];
		  myFunction();
		}
	  }
	}
	//
	//
	// *******************************************************************
	//
	//
	// API
	//
	//
	// *******************************************************************
	public function addFunction(thisFunction:Function):void {
	  if(pFunctions.indexOf(thisFunction)==-1){
		pFunctions.push(thisFunction);
	  }
	}
	public function removeFunction(thisFunction:Function):void {
	  var myIndex:int = pFunctions.indexOf(thisFunction);
	  pFunctions.splice(myIndex,1);
	}
	public function removeAllFunctions():void {
	  pFunctions = new Array();
	}
	//
	//
	// *******************************************************************
	//
	//
	// DESTROY
	//
	//
	// *******************************************************************
	public function destroy():void {
	  removeAllFunctions();
	  pFrameMonitor.removeEventListener(Event.ENTER_FRAME, doIdle);
	}
  }
}