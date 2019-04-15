
waitUntil { time > 0 };

player addAction[ "CP", {
	[] call LARs_fnc_colorPalette;
}];

player addAction[ "CP - out", {
	[ "INIT", [ "RGBA", { hint str _this } ] ] call LARs_fnc_colorPalette;
}];

player addAction[ "CP - exit", {
	[ "INIT", [ "RGBA", { hint str _this }, true, { systemChat "exit"; ctrlParent ( _this select 0 ) closeDisplay 1 } ] ] call LARs_fnc_colorPalette;
}];