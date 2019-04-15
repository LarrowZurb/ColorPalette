
#include "\a3\ui_f\hpp\definedikcodes.inc"
#include "..\ui\colorPalette_IDCs.hpp"
#include "colorPalette_macros.hpp"

disableSerialization;


//diag_log str _this;

params[ [ "_mode", "INIT" ], [ "_this", []  ] ];


switch ( toUpper _mode ) do {

	//Init UI
	case ( "INIT" ) : {
		private[ "_colorPalette" ];
		params[ [ "_format", "" ], [ "_outCode", {} ], [ "_isInternal", true ], [ "_exitCode", {} ] ];
		
		//Load UI
		//If we are loading the display
		if ( _isInternal ) then {
			//Create display
			_display = findDisplay 46 createDisplay "colorPalette";
			//Make sure UI has displayed
			waitUntil{ !isNull ( _display ) };
			//Point UI reference to the controlsGroup
			_colorPalette = _display displayCtrl CP_IDC;
		};
		
		//Save a reference to the UI
		uiNamespace setVariable [ "LARs_colorPalette", _colorPalette ];
		
		//If the parent UI is a display
		if ( ctrlParent _colorPalette isEqualType displayNull ) then {
			//Add display EH
			ctrlParent _colorPalette displayAddEventHandler [ "KeyDown", {
				params[ "_ctrl", "_keyCode" ];
				
				if ( _keyCode isEqualTo DIK_ESCAPE ) then {
					[ "EXIT" ] call LARs_fnc_colorPalette;
				};
			}];
		}else{
			//Add ctrl EH
			_colorPalette ctrlAddEventHandler [ "KeyDown", {
				params[ "_ctrl", "_keyCode" ];
				
				if ( _keyCode isEqualTo DIK_ESCAPE ) then {
					[ "EXIT" ] call LARs_fnc_colorPalette;
				};
			}];
		};

		//Init Color Bars
		{
			_x params[ "_barIDC", "_ttPrefix", "_sliderValue", [ "_barColor", [ 1, 1, 1, 1 ] ], "_barLineColor" ];
			
			//Color Bar & its Mouse Area
			[ "BAR", [ "INIT", [ _barIDC, _ttPrefix, _sliderValue, _barColor, _barLineColor ] ] ] call LARs_fnc_colorPalette;
							
			//Color Slider
			[ "SLIDER", [ "INIT", [ _barIDC, _sliderValue ] ] ] call LARs_fnc_colorPalette;
							
			//Color Edit
			[ "EDIT", [ "INIT", [ _barIDC, _ttPrefix, _sliderValue ] ] ] call LARs_fnc_colorPalette;
							
			//Color Plus/Minus
			[ "VALUE", [ "INIT", [ _barIDC, _ttPrefix ] ] ] call LARs_fnc_colorPalette;
			
		}forEach [
			//	IDC, 			Tooltip, 	Slider value,	Bar color,		Bar Line color
			[ CP_BAR_HUE,		"Hue",			  0,			   nil,		[ 1, 1, 1, 1 ] ],
			[ CP_BAR_SAT,		"Saturation",	100,			   nil,		[ 1, 0, 0, 1 ] ],
			[ CP_BAR_VAL,		"Value",		100,			   nil,		[ 1, 0, 0, 1 ] ],
			[ CP_BAR_RED,		"Red",			255,	[ 1, 0, 0, 1 ],		[ 1, 1, 1, 1 ] ],
			[ CP_BAR_GREEN,		"Green",		  0,	[ 0, 1, 0, 1 ],		[ 1, 1, 1, 1 ] ],
			[ CP_BAR_BLUE,		"Blue",			  0,	[ 0, 0, 1, 1 ],		[ 1, 1, 1, 1 ] ],
			[ CP_BAR_ALPHA,		"Alpha",		100,			   nil,		[ 1, 0, 0, 1 ] ]
		];
		
		//Save out code
		LARs_colorPalette_outCode = _outCode;
		//Save exit code
		LARs_colorPalette_exitCode = _exitCode;
		
		//Palette Area
		[ "PALETTE", "INIT" ] call LARs_fnc_colorPalette;
					
		//Init Format Dropdown
		[ "FORMAT", [ "INIT", [ _format ] ] ] call LARs_fnc_colorPalette;
		
	};
	
	//Exit colorPalette
	case ( "EXIT" ) : {
		//Get UI reference
		_colorPalette = uiNamespace getVariable[ "LARs_colorPalette", controlNull ];
		
		//If we have no exit code
		if ( LARs_colorPalette_exitCode isEqualTo {} ) then {
			//And the UIs parent is a display
			if ( ctrlParent _colorPalette isEqualType displayNull ) then {
				//Close the display
				ctrlParent _colorPalette closeDisplay 1;
			};
		}else{
			//TODO: Needs testing buried in Eden ctrlGroup
			//Call custom exit code - for handling as a Eden nested controlsGroup
			[ _colorPalette ] call LARs_colorPalette_exitCode;
		};
	};
		
	//Save and Load saved colors
	case ( "VARS" ) : {
		params[ "_mode" ];
		
		switch ( toUpper _mode ) do {
			
			//Load Saved Colors
			case ( "LOAD" ) : {
				//Retrieve saved colors
				LARs_colorPalette_savedColors = profileNamespace getVariable[ "LARs_colorPalette_savedColors", [] ];
				//Make sure it has the right number of indexes
				LARs_colorPalette_savedColors resize 12;
				{
					//If index is empty
					if ( isNil "_x" ) then {
						//Add White
						LARs_colorPalette_savedColors set [ _forEachIndex, [ 1, 1, 1, 1 ] ];
					};
				}forEach LARs_colorPalette_savedColors;
				//Save update colors array
				[ "VARS", "SAVE" ] call LARs_fnc_colorPalette;
			};
			
			//Save Saved Colors
			case ( "SAVE" ) : {
				//Save saved colors
				profileNamespace setVariable[ "LARs_colorPalette_savedColors", LARs_colorPalette_savedColors ];
				//Update profile var
				saveProfileNamespace;
			};
			
		};
	};
		
	//Color Bar
	case ( "BAR" ) : {
		params[ "_mode", "_this" ];
		
		switch ( toUpper _mode ) do {
			
			//Set Starting State
			case ( "INIT" ) : {
				params[ "_barIDC", "_ttPrefix", "_sliderValue", "_barColor", "_barLineColor" ];
				
				//Color Bar Mouse Area
				private _colorBarMouseArea = UICTRL( _barIDC );
				_colorBarMouseArea ctrlSetTooltip _ttPrefix;
				
				//Add mouse events
				_colorBarMouseArea ctrlAddEventHandler [ "MouseButtonDown", {
					[ "BAR", [ "DOWN", _this ] ] call LARs_fnc_colorPalette;
				}];
				_colorBarMouseArea ctrlAddEventHandler [ "MouseButtonUp", {
					[ "BAR", [ "UP", _this ] ] call LARs_fnc_colorPalette;
				}];
				
				//Set Color Bar Texture
				private _colorBar = UICTRL( _barIDC + CP_BAR_TEXTURE );
				_colorBar ctrlSetTextColor _barColor;
				
				//Color Bar Line
				[ "BAR", [ "LINE", [ "INIT", [ _barIDC, _sliderValue ] ] ] ] call LARs_fnc_colorPalette;
									
			};
						
			//Mouse Up
			case ( "UP" ) : {
				params[ "_mouseArea", "_button" ];
				
				//Left Mouse & EH running
				if ( _button isEqualTo 0 && !isNil "LARs_colorPalette_bar_EH" ) then {
					//Remove EH
					removeMissionEventHandler [ "EachFrame", LARs_colorPalette_bar_EH ];
					//Clear flag
					LARs_colorPalette_bar_EH = nil;
				};
			};
			
			//Mouse Down
			case ( "DOWN" ) : {
				params[ "_mouseArea", "_button" ];
				
				//Left Mouse
				if ( _button isEqualTo 0 ) then {
					//Add EH
					LARs_colorPalette_bar_EH = addMissionEventHandler [ "EachFrame", format[ "
						[ 'BAR', [ 'MOUSE_MOVING', %1 ] ] call LARs_fnc_colorPalette;
					", ctrlIDC _mouseArea ]];
				};
			};
			
			//Bars Mouse EH
			case ( "MOUSE_MOVING" ) : {
				params[ "_barIDC" ];
				
				//If UI has exited but EH is still running
				if ( isNull UICTRL( CP_IDC ) ) exitWith {
					//Remove EH
					removeMissionEventHandler [ "EachFrame", LARs_colorPalette_bar_EH ];
					//Clear Flag
					LARs_colorPalette_bar_EH = nil;
				};
				
				//Get UI element references
				private _mouseArea = UICTRL( _barIDC );
				private _barLine = UICTRL( _barIDC + CP_BAR_BARLINE );
				private _slider = UICTRL( _barIDC + CP_BAR_SLIDER );
				
				//Get area of Bar
				ctrlPosition _mouseArea params[ "_mouseAreaX", "_mouseAreaY", "_mouseAreaW", "_mouseAreaH" ];
				
				//Remove offset of colorPalette from its ctrlGrpParent from the mouse position
				getMousePosition params[ "_mouseX", "_mouseY" ];
				ctrlPosition UICTRL( CP_IDC )  params[ "_ctrlX", "_ctrlY" ];
				_mouseX = _mouseX - _ctrlX;
				_mouseY = _mouseY - _ctrlY;
				
				//Get Slider Range
				sliderRange _slider params[ "_sliderMin", "_sliderMax" ];
				//Get Bars Increment
				private _inc = [ "BAR", [ "LINE", [ "GETINC", [ _mouseAreaW, _sliderMax ] ] ] ] call LARs_fnc_colorPalette;
				
				//Work out Value of Mouse Position
				private _val = round (( _mouseX - _mouseAreaX ) / _inc );
				_val = _val max _sliderMin min _sliderMax;
				
				//Update Bar elements
				[ "BAR", [ "LINE", [ "SETVALUE", [ _barIDC, _val ] ] ] ] call LARs_fnc_colorPalette;
				[ "SLIDER", [ "SETVALUE", [ _barIDC, _val ] ] ] call LARs_fnc_colorPalette;
				[ "EDIT", [ "SETVALUE", [ _barIDC, _val ] ] ] call LARs_fnc_colorPalette;

			};
			
			
			case ( "LINE" ) : {
				params[ "_mode", "_this" ];
				
				switch ( toUpper _mode ) do {
					
					//Set Starting State
					case ( "INIT" ) : {
						params[ "_barIDC", "_sliderValue" ];
						
						//Create Bar Line
						private _barLine = ( ctrlParent UICTRL( CP_IDC ) ) ctrlCreate [ "ctrlStaticLine", ( _barIDC + CP_BAR_BARLINE ), UICTRL( CP_IDC ) ];
						_barLine ctrlSetTextColor _barLineColor;
						[ "BAR", [ "LINE", [ "SETVALUE", [ _barIDC, _sliderValue ] ] ] ] call LARs_fnc_colorPalette;
					};
					
					//Set Bar Lines value 0-255
					case ( "SETVALUE" ) : {
						params[ "_barIDC", "_val" ];
						
						//Get Bar Lines offset from its Bar
						_pos = [ "BAR", [ "LINE", [ "GETPOS", [ _barIDC, _val ] ] ] ] call LARs_fnc_colorPalette;
						
						//Update its position
						private _barLine = UICTRL( _barIDC + CP_BAR_BARLINE );
						_barLine ctrlSetPosition _pos;
						_barLine ctrlCommit 0;
					};
					
					//Work out Bar Lines UI position
					case ( "GETPOS" ) : {
						params[ "_barIDC", "_val" ];
						
						//Get Bar area
						private _mouseArea = UICTRL( _barIDC );
						ctrlPosition _mouseArea params[ "_mouseAreaX", "_mouseAreaY", "_mouseAreaW", "_mouseAreaH" ];
						
						//Get Bars Slider range
						private _slider = UICTRL( _barIDC + CP_BAR_SLIDER );
						sliderRange _slider params[ "_sliderMin", "_sliderMax" ];
						
						//Get Bars Increment
						private _inc = [ "BAR", [ "LINE", [ "GETINC", [ _mouseAreaW, _sliderMax ] ] ] ] call LARs_fnc_colorPalette;
						
						//Clip the Value to Slider Range
						_val = _val max _sliderMin min _sliderMax;
						
						//Work out Bar Lines offset
						private _offsetX = _val * _inc;
						
						//Return Bar Lines position
						[ _mouseAreaX + _offsetX - ( pixelW / 2 ), _mouseAreaY, pixelW, _mouseAreaH ]							
						
					};
					
					//Get Bars Increment
					case ( "GETINC" ) : {
						params[ "_mouseAreaW", "_sliderMax" ];
						
						//Work out Bar Lines Increment
						private _barInc = _mouseAreaW / _sliderMax;
						
						_barInc							
					};
					
					//Get Bars current value 0-255
					case ( "GETVALUE" ) : {
						params[ "_barIDC" ];
						
						//Get Bars area
						private _mouseArea = UICTRL( _barIDC );
						ctrlPosition _mouseArea params[ "_mouseAreaX", "_mouseAreaY", "_mouseAreaW", "_mouseAreaH" ];
						
						//Get Bar Lines current X
						private _barLine = UICTRL( _barIDC + CP_BAR_BARLINE );
						ctrlPosition _barLine params[ "_lineX" ];
						
						//Get Bar Sliders range
						private _slider = UICTRL( _barIDC + CP_BAR_SLIDER );
						sliderRange _slider params[ "_sliderMin", "_sliderMax" ];
						
						//Get Bars Increment
						private _inc = [ "BAR", [ "LINE", [ "GETINC", [ _mouseAreaW, _sliderMax ] ] ] ] call LARs_fnc_colorPalette;
						
						//Work out Bars current Value
						private _offsetX = ( _lineX + ( pixelW / 2 )) - _mouseAreaX;										
						private _val = round ( _offsetX / _inc );
						
						_val
						
					};
				};
			};
			
		};
	};
		
	//Color Bar Slider
	case ( "SLIDER" ) : {
		params[ "_mode", "_this" ];
		
		switch ( toUpper _mode ) do {
			
			//Set Starting State
			case ( "INIT" ) : {
				params[ "_barIDC", "_sliderValue" ];
				
				//Get Bars Slider
				private _colorBarSlider = UICTRL( _barIDC + CP_BAR_SLIDER );
				//Set Sliders starting position
				_colorBarSlider sliderSetPosition _sliderValue;
				
				//Add Slider EH
				_colorBarSlider ctrlAddEventHandler [ "SliderPosChanged", {
					[ "SLIDER", [ "CHANGED", ( ctrlIDC ( _this select 0 )) - CP_BAR_SLIDER ] ] call LARs_fnc_colorPalette;
				}];
			};
			
			//onSliderPosChanged
			case ( "CHANGED" ) : {
				params[ "_barIDC" ];
				
				//Get Bars Slider
				private _slider = UICTRL( _barIDC + CP_BAR_SLIDER );
				//Get Sliders value
				private _val = round sliderPosition _slider;
				
				//Update Bar components
				[ "SLIDER", [ "SETVALUE", [ _barIDC, _val ] ] ] call LARs_fnc_colorPalette;
				[ "BAR", [ "LINE", [ "SETVALUE", [ _barIDC, _val ] ] ] ] call LARs_fnc_colorPalette;
				[ "EDIT", [ "SETVALUE", [ _barIDC, _val ] ] ] call LARs_fnc_colorPalette;
				
			};
			
			//Set Slider Value
			//Slider Value change handles the updating of the Palette
			case ( "SETVALUE" ) : {
				params[ "_barIDC", "_val" ];
				
				//Get Bars Slider
				private _slider = UICTRL( _barIDC + CP_BAR_SLIDER );
				//Set its position
				_slider sliderSetPosition _val;
				
				//If we have moved HSV
				if ( _barIDC in [ CP_BAR_HUE, CP_BAR_SAT, CP_BAR_VAL ] ) then {
					//Update Palettes Color based on HSV
					[ "PALETTE", [ "GETCOLORVALUE", "HSV" ] ] call LARs_fnc_colorPalette;
				};
				
				//If we have moved RGB
				if ( _barIDC in [ CP_BAR_RED, CP_BAR_GREEN, CP_BAR_BLUE ] ) then {
					//Update Palettes Color based on RGB
					[ "PALETTE", [ "GETCOLORVALUE", "RGB" ] ] call LARs_fnc_colorPalette;
					////Update Palettes Hue
					[ "PALETTE", "SETHUE" ] call LARs_fnc_colorPalette;
				};
				
				//If we have moved ALPHA
				if ( _barIDC in [ CP_BAR_ALPHA ] ) then {
					//Update Palettes Color based on RGB
					[ "PALETTE", [ "GETCOLORVALUE", "RGB" ] ] call LARs_fnc_colorPalette;
				};
				
				//If we have moved HUE
				if ( _barIDC in [ CP_BAR_HUE ] ) then {
					//Update Palettes Hue
					[ "PALETTE", "SETHUE" ] call LARs_fnc_colorPalette;
				};
			};
						
		};
	};
		
	//Color Bar Edit value
	case ( "EDIT" ) : {
		params[ "_mode", "_this" ];
					
		switch ( toUpper _mode ) do {
			
			//Set Starting State
			case ( "INIT" ) : {
				params[ "_barIDC", "_ttPrefix", "_sliderValue" ];
				
				//Get Bars Editbox
				private _colorBarEdit = UICTRL( _barIDC + CP_BAR_EDIT );
				
				//Get Bars Slider range
				private _colorBarslider = UICTRL( _barIDC + CP_BAR_SLIDER );
				sliderRange _colorBarslider params[ "_sliderMin", "_sliderMax" ];
				
				//Set Edit values & tooltip
				_colorBarEdit ctrlSetTooltip format[ "%1 0-%2", _ttPrefix, _sliderMax ];
				_colorBarEdit ctrlSetText str _sliderValue;
				
				//Edit stores its last value for when a no valid entry is made
				_colorBarEdit setVariable[ "lastValid", str _sliderValue ];
				
				//Add Edit EH
				_colorBarEdit ctrlAddEventHandler [ "KeyDown", {
					[ "EDIT", [ "KEY", _this ] ] call LARs_fnc_colorPalette;
				}];
			};
			
			//onKeyDown
			case ( "KEY" ) : {
				params[ "_edit", "_keyCode" ];					
				
				//Get Edits Bar IDC
				private _barIDC = ( ctrlIDC _edit ) - CP_BAR_EDIT; 
									
				//DIK Codes for both keyboard and numpad numbers
				private _numbers = [
					DIK_NUMPAD0, DIK_NUMPAD1, DIK_NUMPAD2, DIK_NUMPAD3, DIK_NUMPAD4,
					DIK_NUMPAD5, DIK_NUMPAD6, DIK_NUMPAD7, DIK_NUMPAD8, DIK_NUMPAD9,
					DIK_0, DIK_1, DIK_2, DIK_3, DIK_4,
					DIK_5, DIK_6, DIK_7, DIK_8, DIK_9
				];
				
				//Dik Codes for allowed special keys
				private _special = [
					DIK_RETURN, DIK_NUMPADENTER, DIK_DELETE, DIK_BACK, DIK_LEFT, DIK_RIGHT, DIK_DECIMAL
				];

				//TODO: This is not working properly
				//If we have pushed an allowed key
				if ( _keyCode in ( _numbers + _special )  ) then {
					
					//If it is the numpad ./Del 
					if ( _keyCode isEqualTo DIK_DECIMAL ) then {
						
						//Get Edits current text
						_text = ctrlText _edit;
						
						//TODO: Remove . and delete char to right and join string
												
						//If text is not a valid number ( . was pushed ) 
						if !( str floor parseNumber _text isEqualTo _text ) then {
							
							//Reset Edit to last valid entry
							_edit ctrlSetText ( _edit getVariable [ "lastValid", "0" ] );
						};
					}else{
						//Get value of Edits text
						private _value = parseNumber ctrlText _edit;
						
						//Get Edit Bars Slider range
						private _slider = UICTRL( _barIDC + CP_BAR_SLIDER );
						sliderRange _slider params[ "_sliderMin", "_sliderMax" ];
						
						//If the value is outside the Sliders range
						if !( _value >= _sliderMin && _value <= _sliderMax ) then {
							//Reset Edit to last valid entry
							_edit ctrlSetText ( _edit getVariable [ "lastValid", "0" ] );
						};
					};
				}else{
					//Something else was pushed
					
					//Get Edit text
					private _text = ctrlText _edit;
					
					//If entry is not a valid number
					if !( str parseNumber _text isEqualTo _text ) then {
						//Rest Edit to last valid entry
						_edit ctrlSetText ( _edit getVariable [ "lastValid", "0" ] );
					};
				};
				
				//Update Edits valid entry
				_edit setVariable[ "lastValid", ctrlText _edit ];
				
				//Get Edits text value
				private _value = parseNumber ctrlText _edit;
				
				//Update Bars components
				[ "EDIT", [ "SETVALUE", [ _barIDC, _value ] ] ] call LARs_fnc_colorPalette;
				[ "BAR", [ "LINE", [ "SETVALUE", [ _barIDC, _value ] ] ] ] call LARs_fnc_colorPalette;
				[ "SLIDER", [ "SETVALUE", [ _barIDC, _value ] ] ] call LARs_fnc_colorPalette;
			};
			
			//Set Edits Value 0-255
			case ( "SETVALUE" ) : {
				params[ "_barIDC", "_val" ];
				
				//If value is a number
				if ( _val isEqualType 0 ) then {
					//Get Bars Slider range
					private _slider = UICTRL( _barIDC + CP_BAR_SLIDER );
					sliderRange _slider params[ "_sliderMin", "_sliderMax" ];
					
					//Make sure value is within Sliders range
					_val = _val max _sliderMin min _sliderMax;
					//Convert value to text
					_val = str _val;
				};
				
				//Get Bars Edit and set its text
				private _edit = UICTRL( _barIDC + CP_BAR_EDIT );
				_edit ctrlSetText _val;
				_edit setVariable[ "lastValid", str _val ];
				
			};
			
			//Increment Edits text value
			case ( "INC" ) : {
				params[ "_barIDC", "_inc" ];
				
				//Get Bars Edit
				private _edit = UICTRL( _barIDC + CP_BAR_EDIT );
				//Get value of Edits text
				private _val = parseNumber ctrlText _edit;
				
				//Increment value
				_val = _val + _inc;
				
				//Update Bars components
				[ "EDIT", [ "SETVALUE", [ _barIDC, _val ] ] ] call LARs_fnc_colorPalette;
				[ "BAR", [ "LINE", [ "SETVALUE", [ _barIDC, _val ] ] ] ] call LARs_fnc_colorPalette;
				[ "SLIDER", [ "SETVALUE", [ _barIDC, _val ] ] ] call LARs_fnc_colorPalette;
			};
						
		};
	};
		
	//Color Bar Value +/- Buttons
	case ( "VALUE" ) : {
		params[ "_mode", "_this" ];
		
		switch ( toUpper _mode ) do {
			
			//Set Starting State
			case ( "INIT" ) : {
				params[ "_barIDC", "_ttPrefix" ];
				
				//Get Bars Plus button
				private _colorBarPlus = UICTRL( _barIDC + CP_BAR_PLUS );
				//Set Buttons tooltip
				_colorBarPlus ctrlSetTooltip format[ "%1 Plus", _ttPrefix ];
				
				//Add button down EH
				_colorBarPlus ctrlAddEventHandler [ "ButtonDown", {
					[ "VALUE", [ "INC", [ "START", _this ] ] ] call LARs_fnc_colorPalette;
				}];
				
				//Add Button up EH
				_colorBarPlus ctrlAddEventHandler [ "ButtonClick", {
					[ "VALUE", [ "INC", "STOP" ] ] call LARs_fnc_colorPalette;
				}];
				
				//Add button exit EH
				_colorBarPlus ctrlAddEventHandler [ "MouseExit", {
					[ "VALUE", [ "INC", "STOP" ] ] call LARs_fnc_colorPalette;
				}];
				
				//Get Bars Minus button
				private _colorBarMinus = UICTRL( _barIDC + CP_BAR_MINUS );
				//Set buttons tooltip
				_colorBarMinus ctrlSetTooltip format[ "%1 Minus", _ttPrefix ];
				
				//Add button down EH
				_colorBarMinus ctrlAddEventHandler [ "ButtonDown", {
					[ "VALUE", [ "DEC", [ "START", _this ] ] ] call LARs_fnc_colorPalette;
				}];
				
				//Add button up EH
				_colorBarMinus ctrlAddEventHandler [ "ButtonClick", {
					[ "VALUE", [ "DEC", "STOP" ] ] call LARs_fnc_colorPalette;
				}];
				
				//Add button exit EH
				_colorBarMinus ctrlAddEventHandler [ "MouseExit", {
					[ "VALUE", [ "DEC", "STOP" ] ] call LARs_fnc_colorPalette;
				}];
			};
			
			//Plus Button
			case ( "INC" ) : {
				params[ "_mode", "_this" ];
				
				switch ( toUpper _mode ) do {
					
					//onButtonDown
					case ( "START" ) : {
						params[ "_ctrl" ];
						
						//Add EH
						//Increment in single steps for first 4 seconds
						//Increment in 5s raising to max 20s
						LARs_colorPalette_value_EH = addMissionEventHandler [ "EachFrame", format[ "
							private[ '_inc' ];
							
							if ( isNull ( uinamespace getvariable [ 'LARs_colorPalette', controlNull ] ) ) exitWith {
								removeMissionEventHandler [ 'EachFrame', LARs_colorPalette_value_EH ];
								LARs_colorPalette_value_EH = nil;
							};
							
							if ( isNil 'LARs_colorPalette_value_timeStart' ) then {
								LARs_colorPalette_value_timeStart = time;
								LARs_colorPalette_value_timeLast = time;
								_inc = 1;
							};
							if ( time - LARs_colorPalette_value_timeStart > 0.5 && time - LARs_colorPalette_value_timeLast > 0.5 ) then {
								_inc = ((floor(( time - LARs_colorPalette_value_timeStart ) / 4 ) min 4 max 0 ) * 5 ) max 1;
								LARs_colorPalette_value_timeLast = time;
							};
							if !( isnil '_inc' ) then {
								[ 'EDIT', [ 'INC', [ %1, _inc ] ] ] call LARs_fnc_colorPalette;
							};
						", ( ctrlIDC _ctrl ) - CP_BAR_PLUS ]];
					};
					
					//onButtonClick
					case ( "STOP" ) : {
						
						//If the EH is still running
						if !( isNil "LARs_colorPalette_value_EH" ) then {
							
							//Remove EH
							removeMissionEventHandler[ "EachFrame", LARs_colorPalette_value_EH ];
							
							//Clear EH start time
							LARs_colorPalette_value_timeStart = nil;
							
							//Clear EH last update time
							LARs_colorPalette_value_timeLast = nil;
							
							//Clear EH flag
							LARs_colorPalette_value_EH = nil;
						};
					};
														
				};
			};
			
			//Minus
			case ( "DEC" ) : {
				params[ "_mode", "_this" ];
				
				switch ( toUpper _mode ) do {
					
					//onButtonDown
					case ( "START" ) : {
						params[ "_ctrl" ];
						
						//Add EH
						//Decrement in single steps for first 4 seconds
						//Decrement in 5s raising to max 20s
						LARs_colorPalette_value_EH = addMissionEventHandler [ "EachFrame", format[ "
							private[ '_inc' ];
							
							if ( isNull ( uinamespace getvariable [ 'LARs_colorPalette', controlNull ] ) ) exitWith {
								removeMissionEventHandler [ 'EachFrame', LARs_colorPalette_value_EH ];
								LARs_colorPalette_value_EH = nil;
							};
							
							if ( isNil 'LARs_colorPalette_value_timeStart' ) then {
								LARs_colorPalette_value_timeStart = time;
								LARs_colorPalette_value_timeLast = time;
								_inc = -1;
							};
							if ( time - LARs_colorPalette_value_timeStart > 0.5 && time - LARs_colorPalette_value_timeLast > 0.5 ) then {
								_inc = -( ((floor(( time - LARs_colorPalette_value_timeStart ) / 4 ) min 4 max 0 ) * 5 ) max 1 );
								LARs_colorPalette_value_timeLast = time;
							};
							if !( isnil '_inc' ) then {
								[ 'EDIT', [ 'INC', [ %1, _inc ] ] ] call LARs_fnc_colorPalette;
							};
						", ( ctrlIDC _ctrl ) - CP_BAR_MINUS ]];
					};
					
					//onButtonClick
					case ( "STOP" ) : {
						
						//If EH still running
						if !( isNil "LARs_colorPalette_value_EH" ) then {
							
							//Remove EH
							removeMissionEventHandler[ "EachFrame", LARs_colorPalette_value_EH ];
							
							//Clear EH start time
							LARs_colorPalette_value_timeStart = nil;
							
							//Clear EH last time
							LARs_colorPalette_value_timeLast = nil;
							
							//Reset EH flag
							LARs_colorPalette_value_EH = nil;
						};
					};
								
				};
			};
		};
	};
		
	//Palette
	case ( "PALETTE" ) : {
		params[ "_mode", "_this" ];
		
		switch ( toUpper _mode ) do {
			
			//Set Starting State
			case ( "INIT" ) : {
				
				//Load Saved Colors
				[ "VARS", "LOAD" ] call LARs_fnc_colorPalette;
				
				//Init Saved Colors Buttons
				{
					private _idc = _x;
					
					//Get Palette Save button
					private _saveButton = UICTRL( _idc + 1 );
					
					//Set Buttons tooltip
					_saveButton ctrlSetTooltip format[ "Save %1", _forEachIndex ];
					
					//Add EH
					_saveButton ctrlAddEventHandler [ "ButtonClick", {
						[ "PALETTE", [ "LOAD_COLOR", ctrlIDC ( _this select 0 ) ] ] call LARs_fnc_colorPalette;
					}];
										
				}forEach [
					CP_SAVE_0, CP_SAVE_1, CP_SAVE_2, CP_SAVE_3, CP_SAVE_4, CP_SAVE_5,
					CP_SAVE_6, CP_SAVE_7, CP_SAVE_8, CP_SAVE_9, CP_SAVE_10, CP_SAVE_11
				];
				
				//Update Palettes Saved Color buttons
				[ "PALETTE", "UPDATE_BUTTONS" ] call LARs_fnc_colorPalette;
				
				//Init Palette color
				private _palette = UICTRL( CP_PALETTE );
				_palette ctrlSetTextColor [ 1, 0, 0, 1 ];
				
				//Get Palette
				private _paletteArea = UICTRL( CP_MOUSEAREA );
				//Update Palette colors from HSV & RGB values
				[ "PALETTE", [ "GETCOLORVALUE", "HSV" ] ] call LARs_fnc_colorPalette;
				[ "PALETTE", [ "GETCOLORVALUE", "RGB" ] ] call LARs_fnc_colorPalette;
				
				//Add mouse down EH
				_paletteArea ctrlAddEventHandler [ "MouseButtonDown", {
					[ "PALETTE", [ "MOUSE_AREA", [ "DOWN", _this ] ] ] call LARs_fnc_colorPalette;
				}];
				
				//Add mouse up EH
				_paletteArea ctrlAddEventHandler [ "MouseButtonUp", {
					[ "PALETTE", [ "MOUSE_AREA", [ "UP", _this ] ] ] call LARs_fnc_colorPalette;
				}];
				
				//Init Palette Saturation & Value Lines
				[ "PALETTE", [ "LINES", [ "INIT", _paletteArea ] ] ] call LARs_fnc_colorPalette;
				
			};
			
			//Palette mouse area
			case ( "MOUSE_AREA" ) : {
				params[ "_mode", "_this" ];
				
				switch ( toUpper _mode ) do {
					
					//Mouse Up
					case ( "UP" ) : {
						params[ "_palette", "_button" ];
						
						//Left Mouse Button & currently tracking
						if ( _button isEqualTo 0 && !isNil "LARs_colorPalette_palette_EH" ) then {
							
							//Remove Mouse Position tracking
							removeMissionEventHandler [ "EachFrame", LARs_colorPalette_palette_EH ];
							
							//Remove flag
							LARs_colorPalette_palette_EH = nil;
						};
					};
					
					//Mouse Down
					case ( "DOWN" ) : {
						params[ "_palette", "_button" ];
						
						//Left Mouse Button
						if ( _button isEqualTo 0 ) then {
							
							//Add event to track mouse position
							LARs_colorPalette_palette_EH = addMissionEventHandler [ "EachFrame", format[ "
								[ 'PALETTE', [ 'MOUSE_AREA', [ 'MOUSE_MOVING', %1 ] ] ] call LARs_fnc_colorPalette;
							", ctrlIDC _palette ]];
						};
					};
					
					//Palette mouse moving EH
					case ( "MOUSE_MOVING" ) : {
						params[ "_idc" ];
						
						//If the UI has been exited
						if ( isNull UICTRL( CP_IDC ) ) exitWith {
							//Remove the EH
							removeMissionEventHandler [ 'EachFrame', LARs_colorPalette_palette_EH ];
							//Clear EH flag
							LARs_colorPalette_palette_EH = nil;
						};
						
						//Get Palette Mouse Area
						private _palette = UICTRL( _idc );
						//Get Mouse Area position and size
						private _palettePos = ctrlPosition _palette;
						_palettePos params[ "_paletteX", "_paletteY" ];
						
						//Get current Mouse Position
						getMousePosition params[ "_mouseX", "_mouseY" ];
						
						//Remove offset of colorPalette to its ctrlGrpParent from the mouse position
						ctrlPosition UICTRL( CP_IDC ) params[ "_ctrlX", "_ctrlY" ];
						_mouseX = _mouseX - _ctrlX;
						_mouseY = _mouseY - _ctrlY;

						
						//Get screen space increments for VAL & SAT
						( [ "PALETTE", [ "LINES", [ "GETINC", _palettePos ] ] ] call LARs_fnc_colorPalette ) params[ "_incX", "_incY" ];
						_incX params[ "_incVal" ];
						_incY params[ "_incSat", "_incSatMin", "_incSatMax" ];
						
						//Work out VAL & SAT values based on current mouse position
						private _valueVal = round(( _mouseX - _paletteX ) / _incVal );
						private _valueSat = _incSatMax - round(( _mouseY - _paletteY ) / _incSat );
						
						//Set VAL & SAT bar line, edit and slider
						{
							_x params[ "_idc", "_value" ];
							
							private _slider = UICTRL( _idc + CP_BAR_SLIDER );
							_slider sliderSetPosition _value;
							
							[ "BAR", [ "LINE", [ "SETVALUE", [ _idc, _value ] ] ] ] call LARs_fnc_colorPalette;
							[ "EDIT", [ "SETVALUE", [ _idc, _value ] ] ] call LARs_fnc_colorPalette;
						}forEach [
							[ CP_BAR_VAL, _valueVal ],
							[ CP_BAR_SAT, _valueSat ]
						];

						//Set Palette line positions
						[ "PALETTE", [ "LINES", [ "SETVALUE", [ _valueVal, _valueSat ] ] ] ] call LARs_fnc_colorPalette;
						
						//Update HSV values
						[ "PALETTE", [ "GETCOLORVALUE", "HSV" ] ] call LARs_fnc_colorPalette;

					};
					
				};
				
			};
			
			//Set Current Color color
			case ( "SETCOLOR" ) : {
				params[ "_color" ];
				
				//Get Current Color UI component
				private _currentColor = UICTRL( CP_COLOR );
				//Update its color
				_currentColor ctrlSetTextColor _color;
				//Save Current Color values on control - used to retrieve the current color as there is no ctrlTextColor command
				_currentColor setVariable [ "color", _color ];
				
				//Update Format Output
				[ "FORMAT", "OUTPUT" ] call LARs_fnc_colorPalette;
			};
			
			//Set Palette hue color
			case ( "SETHUE" ) : {
				
				//Get values of RGB & Saturation & Hue Bar Lines
				private _R = [ "BAR", [ "LINE", [ "GETVALUE", CP_BAR_RED ] ] ] call LARs_fnc_colorPalette;
				private _G = [ "BAR", [ "LINE", [ "GETVALUE", CP_BAR_GREEN ] ] ] call LARs_fnc_colorPalette;
				private _B = [ "BAR", [ "LINE", [ "GETVALUE", CP_BAR_BLUE ] ] ] call LARs_fnc_colorPalette;
				private _S = [ "BAR", [ "LINE", [ "GETVALUE", CP_BAR_SAT ] ] ] call LARs_fnc_colorPalette;
				private _H = [ "BAR", [ "LINE", [ "GETVALUE", CP_BAR_HUE ] ] ] call LARs_fnc_colorPalette;
				
				//Get RGB min & max
				private _max = selectMax[ _R, _G, _B ];
				private _min = selectMin[ _R, _G, _B ];
				
				//If saturation is 0 or all RGB values are the same
				private _RGB = if ( _S isEqualTo 0 || ( _max - _min ) isEqualTo 0 ) then {
					//Convert Hue to 0-1
					private _hue = linearConversion[ 0, 360, _H, 0, 1 ];
					//Get Palettes Hue color
					[ "PALETTE", [ "GETHUECOLOR", [ _hue, 1, 1 ] ] ] call LARs_fnc_colorPalette
				}else{
					//Convert RGB to 0-1
					[ 
						linearConversion[ _min, _max, _R, 0, 1 ],
						linearConversion[ _min, _max, _G, 0, 1 ], 
						linearConversion[ _min, _max, _B, 0, 1 ]
					]
				};
				
				//Extract RGB values
				_RGB params[ "_R", "_G", "_B" ];

				//Update Palettes color ( Hue color ) 
				private _palette = UICTRL( CP_PALETTE );
				_palette ctrlSetTextColor [ _R, _G, _B, 1 ];
				_palette ctrlSetActiveColor [ _R, _G, _B, 1 ];
				
			};
			
			//Set Current Color alpha
			case ( "SETALPHA" ) : {
				params[ "_alpha" ];
				
				//Get Current Color 
				private _currentColor = UICTRL( CP_COLOR );
				//Retrieve store current color
				private _color = _currentColor getVariable "color";
				//Set the Alpha
				_color set [ 3, _alpha ];
				
				//Get Current Colors background
				//this is white at fullcolor but gets its Alpha set so as a a color with no alpha does not look like its white
				private _currentColorBackground = UICTRL( CP_COLOR_BCK );
				//Set its TEXT as a procedural white texture with alpha
				_currentColorBackground ctrlSetText format[ "#(argb,8,8,3)color(1,1,1,1)", _alpha ];
				
				//Update Palettes color
				[ "PALETTE", [ "SETCOLOR", _color ] ] call LARs_fnc_colorPalette;
				
			};
			
			//Load a Saved color
			case ( "LOAD_COLOR" ) : {
				params[ "_idc" ];
				
				//Get Buttons index in the saved colors list
				//Every idc is the Saved Buttons background color which indicates the saved color
				//Every other idc is the actual Button
				//the button is nothing more than a button with a whole so you can see the color through it
				_index = (( _idc - 1 ) - CP_SAVE_0 ) / 2;
				
				//Get the saved color
				( LARs_colorPalette_savedColors select _index ) params[ "_R", "_G", "_B", "_Alpha" ];
				
				//Convert RBGA from 0-1 to 0-255/100
				_R = round linearConversion[ 0, 1, _R, 0, 255 ];
				_G = round linearConversion[ 0, 1, _G, 0, 255 ];
				_B = round linearConversion[ 0, 1, _B, 0, 255 ];
				_Alpha = round linearConversion[ 0, 1, _Alpha, 0, 100 ];
				
				//Get Red Bars Slider
				private _slider = UICTRL( CP_BAR_RED + CP_BAR_SLIDER );
				//Update its position
				//this does not fire onSliderChanged and is not "SETVALUE" so as not to incur a Paleete update loop
				_slider sliderSetPosition _R;
				//Update Red Bar Edit & Line
				[ "EDIT", [ "SETVALUE", [ CP_BAR_RED, _R ] ] ] call LARs_fnc_colorPalette;
				[ "BAR", [ "LINE", [ "SETVALUE", [ CP_BAR_RED, _R ] ] ] ] call LARs_fnc_colorPalette;
				
				//Get Green Bar Slider
				_slider = UICTRL( CP_BAR_GREEN + CP_BAR_SLIDER );
				//Update its position
				_slider sliderSetPosition _G;
				//Update Green Bar Edit & Line
				[ "EDIT", [ "SETVALUE", [ CP_BAR_GREEN, _G ] ] ] call LARs_fnc_colorPalette;
				[ "BAR", [ "LINE", [ "SETVALUE", [ CP_BAR_GREEN, _G ] ] ] ] call LARs_fnc_colorPalette;
				
				//Get Blue Bar Slider
				_slider = UICTRL( CP_BAR_BLUE + CP_BAR_SLIDER );
				//Update its position
				_slider sliderSetPosition _B;
				//Update Blur Bar Edit & Line
				[ "EDIT", [ "SETVALUE", [ CP_BAR_BLUE, _B ] ] ] call LARs_fnc_colorPalette;
				[ "BAR", [ "LINE", [ "SETVALUE", [ CP_BAR_BLUE, _B ] ] ] ] call LARs_fnc_colorPalette;
				
				//Get Alpha Bar Slider
				_slider = UICTRL( CP_BAR_ALPHA + CP_BAR_SLIDER );
				//Update its position
				_slider sliderSetPosition _Alpha;
				//Update Alpha Bar Edit & Line
				[ "EDIT", [ "SETVALUE", [ CP_BAR_ALPHA, _Alpha ] ] ] call LARs_fnc_colorPalette;
				[ "BAR", [ "LINE", [ "SETVALUE", [ CP_BAR_ALPHA, _Alpha ] ] ] ] call LARs_fnc_colorPalette;
				
				//Update Palette via RGB
				[ "PALETTE", [ "GETCOLORVALUE", "RGB" ] ] call LARs_fnc_colorPalette;
				//Update Palette Hue
				[ "PALETTE", "SETHUE" ] call LARs_fnc_colorPalette;
			};
			
			//Save Current Color
			case ( "SAVE_COLOR" ) : {
				
				//For each save button BACKGROUND backwards
				for "_idc" from CP_SAVE_11 to CP_SAVE_1 step - 2 do {
					
					//Get the button before it
					private _previousButtonColor = UICTRL( _idc - 2 );
					
					//Get its color
					private _color = _previousButtonColor getVariable [ "color", [ 1, 1, 1, 1 ] ];
					
					//Update Saved Colors Array
					LARs_colorPalette_savedColors set [ ( _idc - CP_SAVE_0 ) / 2, _color ];
					
				};
				
				//Get Current Color UI component
				private _currentColor = UICTRL( CP_COLOR );
				//Get its current color value
				private _color = _currentColor getVariable "color";
				
				//Set first color
				LARs_colorPalette_savedColors set [ 0, _color ];
				
				//Save profile var
				[ "VARS", "SAVE" ] call LARs_fnc_colorPalette;
				
				//Update button colors
				[ "PALETTE", "UPDATE_BUTTONS" ] call LARs_fnc_colorPalette;
								
			};
			
			//Update Saved Color Buttons
			case ( "UPDATE_BUTTONS" ) : {
				{
					private _idc = _x;
					
					//Get the Button BACKGROUND
					private _saveColor = UICTRL( _idc );
					//Get the saved color
					private _color = ( LARs_colorPalette_savedColors select _forEachIndex );
					
					//Update Buttons BACKGROUND color
					_saveColor ctrlSetTextColor _color;
					_saveColor ctrlSetActiveColor _color;
					//Save color value on the control
					_saveColor setVariable [ "color", _color ];
										
				}forEach [
					//Save Button BACKGROUNDS
					CP_SAVE_0, CP_SAVE_1, CP_SAVE_2, CP_SAVE_3, CP_SAVE_4, CP_SAVE_5,
					CP_SAVE_6, CP_SAVE_7, CP_SAVE_8, CP_SAVE_9, CP_SAVE_10, CP_SAVE_11
				];
			};
			
			//Get Hue color for Palette
			case ( "GETHUECOLOR" ) : {
				params[ "_hue", "_saturation", "_value" ];
				
				//Make sure Hue is 0- < 1
				if ( _hue isEqualTo 1 ) then {
					_hue = 0;
				};
				
				private _Htmp = _hue * 6;
				
				//Work out color values
				private _i = floor _Htmp;
				private _val_1 = _value * ( 1 - _saturation );
				private _val_2 = _value * ( 1 - _saturation * ( _Htmp - _i ));
				private _val_3 = _value * ( 1 - _saturation * ( 1 - ( _Htmp - _i )));
           		
           		//Get RGB based on Hue
           		private _R = [ _value, _val_2, _val_1, _val_1, _val_3, _value ] select _i;
           		private _G = [ _val_3, _value, _value, _val_2, _val_1, _val_1 ] select _i;
           		private _B = [ _val_1, _val_1, _val_3, _value, _value, _val_2 ] select _i;
           		
           		[ _R, _G, _B ]
			};
			
			//Work out Palette color based of off HSV or RGB
			case ( "GETCOLORVALUE" ) : {
				params[ "_mode", "_this" ];
				
				//Temp var to save converted values
				private _colorValues = [];
				
				//Convert values to 0-1
				{
					//Get Bars Slider Range
					private _slider = UICTRL( _x + CP_BAR_SLIDER );
					sliderRange _slider params[ "_sliderMin", "_sliderMax" ];
					//Convert based on Slider max
					private _nul = _colorValues pushBack (( sliderPosition _slider ) / _sliderMax );
				}forEach[
					CP_BAR_HUE,
					CP_BAR_SAT,
					CP_BAR_VAL,
					CP_BAR_RED,
					CP_BAR_GREEN,
					CP_BAR_BLUE,
					CP_BAR_ALPHA
				];

				//Extract Converted values
				_colorValues params[ "_hue", "_saturation", "_value", "_R", "_G", "_B", "_alpha" ];

				switch ( toUpper _mode ) do {
					
					//When HSV has changed
					case ( "HSV" ) : {
						
						//If Saturation is 0 then color values must be all the same
						private _RGB = if ( _saturation isEqualTo 0 ) then {
							[ _value, _value, _value ]
						}else{
							//Else get current HUE color
							[ "PALETTE", [ "GETHUECOLOR", [ _hue, _saturation, _value ] ] ] call LARs_fnc_colorPalette
						};
						
						_RGB params[ "_R", "_G", "_B" ];
						
						//Set Current Color
						[ "PALETTE", [ "SETCOLOR", [ [ _R, _G, _B, _alpha ] ] ] ] call LARs_fnc_colorPalette;
						
						//Convert color values back to 0-255
						_R = round linearConversion[ 0, 1, _R, 0, 255 ];
						_G = round linearConversion[ 0, 1, _G, 0, 255 ];
						_B = round linearConversion[ 0, 1, _B, 0, 255 ];
						
						//Apply values to RGB bar line, slider and edit
						{
							_x params[ "_idc", "_val" ];
							
							//Get Bars Slider
							private _slider = UICTRL( _idc + CP_BAR_SLIDER );
							//Set its value
							_slider sliderSetPosition _val;
							
							//Set Bars Edit & Line values
							[ "EDIT", [ "SETVALUE", [ _idc, _val ] ] ] call LARs_fnc_colorPalette;
							[ "BAR", [ "LINE", [ "SETVALUE", [ _idc, _val ] ] ] ] call LARs_fnc_colorPalette;
						}forEach [
							[ CP_BAR_RED, _R ],
							[ CP_BAR_GREEN, _G ],
							[ CP_BAR_BLUE, _B ]
						];
						
						//If we are not currently moving the palette lines
						if ( isNil "LARs_colorPalette_palette_EH" ) then {
							//Then update their values 0-100
							[ "PALETTE", [ "LINES", [ "SETVALUE", [ linearConversion[ 0, 1, _value, 0, 100 ], linearConversion[ 0, 1, _saturation, 0, 100 ] ] ] ] ] call LARs_fnc_colorPalette;
						};
						
					};
					
					//When RGB has changed				
					case ( "RGB" ) : {

						//Temp RGB
						private _Rtmp = _R;
						private _Gtmp = _G;
						private _Btmp = _B;

						//Get min max color vlaue
						private _min = selectMin[ _Rtmp, _Gtmp, _Btmp ];
						private _max = selectMax[ _Rtmp, _Gtmp, _Btmp ];
						//Work out delta between min max
						private _deltaMax = _max - _min;

						//Value must be max
						_value = _max;

						//If there is 0 delta then Saturation & Hue must be 0
						if ( _deltaMax isEqualTo 0 ) then {
							_hue = 0;
							_saturation = 0;
						}else{
							_saturation = _deltaMax / _max;

							private _deltaR = ((( _max - _Rtmp ) / 6 ) + ( _deltaMax / 2 )) / _deltaMax;
							private _deltaG = ((( _max - _Gtmp ) / 6 ) + ( _deltaMax / 2 )) / _deltaMax;
							private _deltaB = ((( _max - _Btmp ) / 6 ) + ( _deltaMax / 2 )) / _deltaMax;

							_hue = switch( _max ) do {
								case( _Rtmp ) : {
									_deltaB - _deltaG
								};
								case( _Gtmp ) : {
									( 1 / 3 ) + _deltaR - _deltaB
								};
								case( _Btmp ) : {
									( 2 / 3 ) + _deltaG - _deltaR
								};
							};

							if ( _hue < 0 ) then { _hue = _hue + 1; };
							if ( _hue > 1 ) then { _hue = _hue - 1; };
							
						};
						
						//Set Current Color
						[ "PALETTE", [ "SETCOLOR", [ [ _R, _G, _B, _alpha ] ] ] ] call LARs_fnc_colorPalette;
						
						//Convert HSV back into full values
						_hue = round linearConversion[ 0, 1, _hue, 0, 360 ];
						_saturation = round linearConversion[ 0, 1, _saturation, 0, 100 ];
						_value = round linearConversion[ 0, 1, _value, 0, 100 ];

						//Apply values to HSV bar line, slider and edit
						{
							_x params[ "_idc", "_val" ];
							
							//Get Bars Slider
							private _slider = UICTRL( _idc + CP_BAR_SLIDER );
							//Set its position
							_slider sliderSetPosition _val;
							
							//Set Bars Edit & Line values
							[ "EDIT", [ "SETVALUE", [ _idc, _val ] ] ] call LARs_fnc_colorPalette;
							[ "BAR", [ "LINE", [ "SETVALUE", [ _idc, _val ] ] ] ] call LARs_fnc_colorPalette;
						}forEach [
							[ CP_BAR_HUE, _hue ],
							[ CP_BAR_SAT, _saturation ],
							[ CP_BAR_VAL, _value ]
						];
						
						//If we are not currently moving the palette lines
						if ( isNil "LARs_colorPalette_palette_EH" ) then {
							//Then update their values
							[ "PALETTE", [ "LINES", [ "SETVALUE", [ _value, _saturation ] ] ] ] call LARs_fnc_colorPalette;
						};

					};
					
				};
			
			};
			
			//Palette Satruation & Value Lines
			case ( "LINES" ) : {
				params[ "_mode", "_this" ];
				
				switch ( toUpper _mode ) do {
					
					//Set Starting State
					case ( "INIT" ) : {
						
						{
							_x params[ "_idc", "_color" ];
							
							//Create Line
							private _line = ( ctrlParent UICTRL( CP_IDC ) ) ctrlCreate [ "ctrlStaticLine", _idc, UICTRL( CP_IDC ) ];
							//Set its color
							_line ctrlSetTextColor _color;
														
						}forEach [
							[ CP_LINE_VERT_W, [ 1, 1, 1, 1 ] ],
							[ CP_LINE_VERT_B, [ 0, 0, 0, 1 ] ],
							[ CP_LINE_HORI_W, [ 1, 1, 1, 1 ] ],
							[ CP_LINE_HORI_B, [ 0, 0, 0, 1 ] ]
						];
						
						//Set Lines positions
						[ "PALETTE", [ "LINES", [ "SETVALUE",
							[ 
								sliderPosition ( UICTRL( CP_BAR_VAL + CP_BAR_SLIDER )),
								sliderPosition ( UICTRL( CP_BAR_SAT + CP_BAR_SLIDER ))
							]
						 ] ] ] call LARs_fnc_colorPalette;
					};
					
					//Set Lines value
					case ( "SETVALUE" ) : {
						params[ "_valueVal", "_valueSat" ];

						//Get Palette 
						private _palette = UICTRL( CP_PALETTE );
						//Get its position
						private _palettePos = ctrlPosition _palette;
								
						//Get Palettes Lines positions
						( [ "PALETTE", [ "LINES", [ "GETPOS", [ _valueVal, _valueSat, _palettePos ] ] ] ] call LARs_fnc_colorPalette ) params[ "_posX", "_posY" ];
						
						//Get Palettes position values
						_palettePos params[ "_paletteX", "_paletteY", "_paletteW", "_paletteH" ];
						
						//Update Palette Line positions
						{
							_x params[ "_idc", "_pos" ];
							
							private _line = UICTRL( _idc );
							_line ctrlSetPosition _pos;
							_line ctrlCommit 0;
							
						}forEach [
							[ CP_LINE_VERT_W, [
								_posX - pixelW,
								_paletteY,
								pixelW,
								_paletteH
							]],
							[ CP_LINE_VERT_B, [
								_posX,
								_paletteY,
								pixelW,
								_paletteH
							]],
							[ CP_LINE_HORI_W, [
								_paletteX,
								_posY - pixelH,
								_paletteW,
								pixelH
							]],
							[ CP_LINE_HORI_B, [
								_paletteX,
								_posY,
								_paletteW,
								pixelH
							]]
						];
					};
					
					//Get Palette Lines position
					case ( "GETPOS" ) : {
						params[ "_valueVal", "_valueSat", "_palettePos" ];
						
						//Get Palette position
						_palettePos params[ "_paletteX", "_paletteY", "_paletteW", "_paletteH" ];
						
						//Get Palette Line Incrementts
						( [ "PALETTE", [ "LINES", [ "GETINC", _palettePos ] ] ] call LARs_fnc_colorPalette ) params[ "_incX", "_incY" ];
						_incX params[ "_incVal", "_incValMin", "_incValMax" ];
						_incY params[ "_incSat", "_incSatMin", "_incSatMax" ];
						
						//Clip Value to min max
						_valueVal = _valueVal max _incValMin min _incValMax;
						//Clip Saturation to min max - reversed as on the Palette saturation climbs as you go up
						_valueSat = ( _incSatMax - _valueSat ) max _incSatMin min _incSatMax;
						
						[ _paletteX + ( _valueVal * _incVal ) , _paletteY + ( _valueSat * _incSat ) ]
						
					};
					
					//Get Palette Lines Incremnets
					case ( "GETINC" ) : {
						params[ "_paletteX", "_paletteY", "_paletteW", "_paletteH" ];
												
						//Get Saturation Slider min max						
						private _sliderSat = UICTRL( CP_BAR_SAT + CP_BAR_SLIDER );
						sliderRange _sliderSat params[ "_sliderSatMin", "_sliderSatMax" ];
										
						//Get Value Slider min max
						private _sliderVal = UICTRL( CP_BAR_VAL + CP_BAR_SLIDER );
						sliderRange _sliderVal params[ "_sliderValMin", "_sliderValMax" ];
						
						[
							[ _paletteW / _sliderValMax, _sliderValMin, _sliderValMax ],
							[ _paletteH / _sliderSatMax, _sliderSatMin, _sliderSatMax ]
						]
						
					};
					
				};
			};
			
		};
	};			
	
	//All things FORMAT
	case ( "FORMAT" ) : {
		params[ "_mode", "_this" ];
		
		switch ( toUpper _mode ) do {
			params[ "_mode", "_this" ];
			
			//Set Start State
			case ( "INIT" ) : {
				params[ "_format" ];
				
				//Get Format Combo
				private _formatCombo = UICTRL( CP_FORMAT );
				
				//Set its tooltip
				_formatCombo ctrlSetTooltip "Select Output Format";
				
				//Add EH
				_formatCombo ctrlAddEventHandler [ "LBSelChanged", {
					params[ "_ctrl", "_index" ];
					
					private _func = _ctrl lbData _index;
					[ "FORMAT", [ "OUTPUT", _func ] ] call LARs_fnc_colorPalette;
				}];
				
				//Fill Combo options
				{
					_x params[ "_title", "_func" ];
					
					//If no specific format was asked for OR the title matches the format
					if ( _format isEqualTo "" || { _format == _func } ) then {
						
						//Add entry
						private _index = _formatCombo lbAdd _title;
						
						//Store function in data
						_formatCombo lbSetData[ _index, _func ];
						
						//Set all entry tooltips
						_formatCombo lbSetTooltip[ _index, "Select Output Format" ];
					};
				}forEach [
					//Title, 				function
					[ "RGBA 0-1",			"RGBA" ],
					[ "RGBA 0-255",			"RGBAV" ],
					[ "RGBA Html",			"RGBAH" ],
					[ "RGB Html",			"RGBH" ],
					[ "Procedural Texture",	"PROCEDURAL" ]
				];
				
				//Set current as first
				_formatCombo lbSetCurSel 0;
				
				//If we have been passed an outCode change CTC button picture to save
				if !( LARs_colorPalette_outCode isEqualTo {} ) then {
					//Get CTC Button
					_CTC_Button = UICTRL( CP_CTC );
					//Set Texture to Save
					_CTC_Button ctrlSetText "\a3\3den\data\displays\display3den\toolbar\save_ca.paa";
					//Set tooltip
					_CTC_Button ctrlSetTooltip "Exit with Colour";
				};
			};
			
			//format color
			case ( "FORMAT" ) : {
				params[ "_mode", "_this" ];
				
				//Get Current Color component
				private _currentColor = UICTRL( CP_COLOR );
				//Get its saved color
				private _color = _currentColor getVariable "color";
				
				_color params[ "_R", "_G", "_B", "_Alpha" ];
				
				switch ( toUpper _mode ) do {
					
					//OUTPUT functions for formatting colors
					//RGBA 0-1
					case ( "RGBA" ) : {
						format[ "%1, %2, %3, %4", _R, _G, _B, _Alpha ];
						
					};
					
					//RGBAV 0-255
					case ( "RGBAV" ) : {
						format[ "%1, %2, %3, %4",
							round linearConversion[ 0, 1, _R, 0, 255 ],
							round linearConversion[ 0, 1, _G, 0, 255 ],
							round linearConversion[ 0, 1, _B, 0, 255 ],
							round linearConversion[ 0, 1, _Alpha, 0, 255 ]
						];
					};
					
					//RGBAHtml
					case ( "RGBAH" ) : {
						//Thankyou BI
						_color call BIS_fnc_colorRGBAtoHTML;
					};
					
					//RGBHtml
					case ( "RGBH" ) : {
						//Thankyou BI
						_color call BIS_fnc_colorRGBtoHTML;
					};
					
					//Procedural Texture
					case ( "PROCEDURAL" ) : {
						//Thankyou BI
						_color call BIS_fnc_colorRGBAtoTexture;
					};
					
					//opps
					default { "" };
					
				};
			};
			
			//Set the OUTPUT contents
			case ( "OUTPUT" ) : {
				params[ "_func" ];
				
				//If we do not have function
				if ( isNil "_func" ) then {
					//Get Combo
					private _formatCombo = UICTRL( CP_FORMAT );
					//Get Combo current index
					private _index = lbCurSel _formatCombo;
					//Get function from Combo data
					_func = _formatCombo lbData _index;
				};
				
				//Call the function
				private _output = [ "FORMAT", [ "FORMAT", _func ] ] call LARs_fnc_colorPalette;
				
				//Get Format Editbox
				private _edit = UICTRL(  CP_OUTPUT );
				//Set Edits text
				_edit ctrlSetText _output;				
				
			};
			
			//OUTPUT copyToClipboard
			case ( "COPYTOCLIPBOARD" ) : {
				//Get Format Edit
				private _edit = UICTRL( CP_OUTPUT );
				//Get Format Edit text
				_text = ctrlText _edit;
				
				//If we have no outCode
				if ( LARs_colorPalette_outCode isEqualTo {} ) then {
					//Copy its text to the clipboard
					copyToClipboard _text;
					//Give user feedback
					hint "Output copied to clipboard";
				}else{
					//Exit
					[ "EXIT" ] call LARs_fnc_colorPalette;
					//Call outCode passing choosen color as STRING
					[ _text ] call LARs_colorPalette_outCode;
				};
			};
			
			//INPUT
			//TODO: maybe, needs descent error checking for format
//			case ( "COPYFROMCLIPBOARD" ) : {
//				
//				private[ "_R", "_G", "_B", "_A" ];
//				
//				private _pasted = copyFromClipboard;
//				
//				private _formatCombo = UICTRL( CP_FORMAT );
//				private _index = lbCurSel _formatCombo;
//				private _func = _formatCombo lbData _index;
//				
//				switch ( toUpper _func ) do {
//					
//					case ( "RGBA" ) : {
//						private _valueStrArray = _pasted splitString ",";
//						private _values = _valueStrArray apply{ parseNumber _x };
//						_values params[ "_R", "_G", "_B", [ "_A", 1 ] ];
//						
//						{
//							_x params[ "_idc", "_value" ];
//							
//							private _slider = UICTRL( _idc );
//							_slider sliderSetPosition _value;
//							
//							[ "EDIT", [ "SETVALUE", [ _idc, _value ] ] ] call LARs_fnc_colorPalette;
//							[ "BAR", [ "LINE", [ "SETVALUE", [ _idc, _value ] ] ] ] call LARs_fnc_colorPalette;
//						}forEach [
//							[ CP_BAR_RED, round linearConversion[ 0, 1, _R, 0, 255, true ] ],
//							[ CP_BAR_GREEN, round linearConversion[ 0, 1, _G, 0, 255, true ] ],
//							[ CP_BAR_BLUE, round linearConversion[ 0, 1, _B, 0, 255, true ] ],
//							[ CP_BAR_ALPHA, round linearConversion[ 0, 1, _A, 0, 255, true ] ]
//						];
//					};
//					
//					
//					case ( "RGBV" ) : {
//						private _valueStrArray = _pasted splitString ",";
//						private _values = _valueStrArray apply{ parseNumber _x };
//						_values params[ "_R", "_G", "_B", [ "_A", 1 ] ];
//						
//						{
//							_x params[ "_idc", "_value" ];
//							
//							private _slider = UICTRL( _idc );
//							_slider sliderSetPosition _value;
//							
//							[ "EDIT", [ "SETVALUE", [ _idc, _value ] ] ] call LARs_fnc_colorPalette;
//							[ "BAR", [ "LINE", [ "SETVALUE", [ _idc, _value ] ] ] ] call LARs_fnc_colorPalette;
//						}forEach [
//							[ CP_BAR_RED, round linearConversion[ 0, 255, _R, 0, 255, true ] ],
//							[ CP_BAR_GREEN, round linearConversion[ 0, 255, _G, 0, 255, true ] ],
//							[ CP_BAR_BLUE, round linearConversion[ 0, 255, _B, 0, 255, true ] ],
//							[ CP_BAR_ALPHA, round linearConversion[ 0, 255, _A, 0, 255, true ] ]
//						];
//						
//					};
//					
//					
//					case ( "RGBAH" ) : {
//						if ( _pasted select[ 0, 1 ] isEqualTo "#" ) then {
//							_pasted = _pasted select [ 1, count _pasted ];
//						};
//						
//						private _hexValues = [ "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F" ];
//						
//						private _fnc_getValue = {
//							params[ "_hexString" ];
//							
//							private _upper = toUpper _hexString select [ 0, 1 ];
//							_upper = ( _hexValue find _upper ) * 16;
//							
//							private _lower = toUpper _hexString select [ 0, 1 ];
//							_lower = ( _hexValue find _lower );
//							
//							_upper + _lower
//						};
//						
//						_A = _pasted select[ 0, 2 ] call _fnc_getValue;
//						_R = _pasted select[ 2, 2 ] call _fnc_getValue;
//						_G = _pasted select[ 4, 2 ] call _fnc_getValue;
//						_B = _pasted select[ 6, 2 ] call _fnc_getValue;
//						
//						{
//							_x params[ "_idc", "_value" ];
//							
//							private _slider = UICTRL( _idc );
//							_slider sliderSetPosition _value;
//							
//							[ "EDIT", [ "SETVALUE", [ _idc, _value ] ] ] call LARs_fnc_colorPalette;
//							[ "BAR", [ "LINE", [ "SETVALUE", [ _idc, _value ] ] ] ] call LARs_fnc_colorPalette;
//						}forEach [
//							[ CP_BAR_RED, round linearConversion[ 0, 255, _R, 0, 255, true ] ],
//							[ CP_BAR_GREEN, round linearConversion[ 0, 255, _G, 0, 255, true ] ],
//							[ CP_BAR_BLUE, round linearConversion[ 0, 255, _B, 0, 255, true ] ],
//							[ CP_BAR_ALPHA, round linearConversion[ 0, 255, _A, 0, 255, true ] ]
//						];
//						
//					};
//					
//					
//					case ( "RGBH" ) : {
//						if ( _pasted select[ 0, 1 ] isEqualTo "#" ) then {
//							_pasted = _pasted select [ 1, count _pasted ];
//						};
//						
//						private _hexValues = [ "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F" ];
//						
//						private _fnc_getValue = {
//							params[ "_hexString" ];
//							
//							private _upper = toUpper _hexString select [ 0, 1 ];
//							_upper = ( _hexValue find _upper ) * 16;
//							
//							private _lower = toUpper _hexString select [ 0, 1 ];
//							_lower = ( _hexValue find _lower );
//							
//							_upper + _lower
//						};
//						
//						_R = _pasted select[ 2, 2 ] call _fnc_getValue;
//						_G = _pasted select[ 4, 2 ] call _fnc_getValue;
//						_B = _pasted select[ 6, 2 ] call _fnc_getValue;
//						
//						{
//							_x params[ "_idc", "_value" ];
//							
//							private _slider = UICTRL( _idc );
//							_slider sliderSetPosition _value;
//							
//							[ "EDIT", [ "SETVALUE", [ _idc, _value ] ] ] call LARs_fnc_colorPalette;
//							[ "BAR", [ "LINE", [ "SETVALUE", [ _idc, _value ] ] ] ] call LARs_fnc_colorPalette;
//						}forEach [
//							[ CP_BAR_RED, round linearConversion[ 0, 1, _R, 0, 255, true ] ],
//							[ CP_BAR_GREEN, round linearConversion[ 0, 1, _G, 0, 255, true ] ],
//							[ CP_BAR_BLUE, round linearConversion[ 0, 1, _B, 0, 255, true ] ],
//							[ CP_BAR_ALPHA, 255 ]
//						];
//						
//					};
//					
//					
//					case ( "PROCEDURAL" ) : {
//						
//						private _valueStrArray = _pasted splitString "(),";
//						reverse _valueStrArray;
//						_valueStrArray = _valueStrArray select[ 0, 4 ];
//						private _values = _valueStrArray apply{ parseNumber _x };
//						reverse _values;
//						_values params[ "_R", "_G", "_B", [ "_A", 1 ] ];
//						
//						{
//							_x params[ "_idc", "_value" ];
//							
//							private _slider = UICTRL( _idc );
//							_slider sliderSetPosition _value;
//							
//							[ "EDIT", [ "SETVALUE", [ _idc, _value ] ] ] call LARs_fnc_colorPalette;
//							[ "BAR", [ "LINE", [ "SETVALUE", [ _idc, _value ] ] ] ] call LARs_fnc_colorPalette;
//						}forEach [
//							[ CP_BAR_RED, round linearConversion[ 0, 1, _R, 0, 255, true ] ],
//							[ CP_BAR_GREEN, round linearConversion[ 0, 1, _G, 0, 255, true ] ],
//							[ CP_BAR_BLUE, round linearConversion[ 0, 1, _B, 0, 255, true ] ],
//							[ CP_BAR_ALPHA, round linearConversion[ 0, 1, _A, 0, 255, true ] ]
//						];
//						
//					};
//				};
//				
//				[ "PALETTE", [ "GETCOLORVALUE", "RGB" ] ] call LARs_fnc_colorPalette;
//				[ "PALETTE", [ "GETCOLORVALUE", "HSV" ] ] call LARs_fnc_colorPalette;
//			};			
		};
	};

};
		
		
		