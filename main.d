//#!rdmd

/* To Dos:
 * More work on input.d [ ]
 * Add resize and save photos that are too big to fit in the display [ ]
 */
//#Note: args[ 0 .. $ ] gets all, args[ 1 .. 3 ] gets 1, & 2
//#Note immutable I think is for concurrancy(sp)
//#doesn't draw strait onto bmp
//#Split isn't clear this way ("foo bar".split), I think
//#dlang.ogg is a funny one
/**
 * Type, Hear and See
 */
module type_hear_and_see;

version(Windows) {
	mixin(Jeca.pragmalibs);
}

version(OSX) {
	mixin(Jeca.pragmalibs);
}

version(linux) {
	pragma( lib, "allegro" );
	pragma( lib, "allegro_primitives" );
	pragma( lib, "allegro_ttf" );
	pragma( lib, "allegro_font" );
	pragma( lib, "allegro_image" );
	pragma( lib, "allegro_audio" );
	pragma( lib, "allegro_acodec" );

	pragma( lib, "jeca" );

	pragma( lib, "dallegro5" );
}

import std.stdio;
import std.string;
import algo = std.algorithm;
import std.typetuple;
import std.path;

import jeca.all;

import base, world;

/**
 * Title: Main program entry
 * 
 * Init JECA, run main class
 */
int main( string[] args ) {
	//#Note: args[ 0 .. $ ] gets all, args[ 1 .. 3 ] gets 1, & 2

		//args = args[ 0 ] ~ "-wxh 640 480 -mode full".split() ~ args[ 1 .. $ ]; //#Split isn't clear this way ("foo bar".split), I think. Less typing though
	//args = args[ 0 ] ~ "-wxh 640 480".split() ~ args[1 .. $];

	version(OSX) {
		return al_run_allegro( {
			init(args);
			return 0;
		} );
	} else {
		init(args);
		return 0;
	}
} // main

int init(string[] args) {
	// JECA init
	//#Note immutable I think is for concurrancy(sp)
	immutable succeed = 0;
	//if ( Init( args, ALLEGRO_INIT | TIMER | KEYBOARD | SOUND | GRAPHICS ) != succeed ) { // No mouse
	if (Init(args) != succeed) {
		return -1;
	}
	scope( exit )
		Deinit;
	
	scope(failure)
		writeln("An error has occured!");
	checkFile("DejaVuSans.ttf").setUpGlobalFont();
	checkFile("abc.png").setUpIcon();

	// create and launch main class object, then start main loop
	try {
		(new World).run();
	} catch( Exception e ) {
		writeln("Got caught in main: ", e.toString());
	}

	return 0;
}

/**
 * Setup font for text
 */
void setUpGlobalFont(string fileName) {
	g_font = al_load_font(fileName.toStringz(), 36, 0); // 18 seemed nice, (but small)
}

/**
 * Set icon for the window
 */
void setUpIcon(string fileName) {
	al_set_display_icon(DISPLAY, Bmp.loadBitmap(fileName));
}
