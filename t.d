//#doesn't draw strait onto bmp
//#Split isn't clear this way ("foo bar".split), I think
/**
 * Type, Hear and See
 */

module type_hear_and_see;

//#over engine eared, I think. But for practice.
//#dlang.ogg is a funny one
pragma( lib, "liballegro5.lib" );
pragma( lib, "libdallegro5.lib" );
pragma( lib, "jeca.lib" );
pragma( lib, "misc.lib" );

import std.stdio;
import std.string;
import algo = std.algorithm;
import std.typetuple;

import jeca.all;
import jtools.misc;

import base, world;

/**
 * Learn more:
 * 
 * http://stackoverflow.com/questions/5630137/for-and-foreach-statements-in-d
 */
static this() {
	foreach( type; TypeTuple!( int, long, short ) ) {
		pragma(msg, type);
	}
}

/**
 * Title: Main program entry
 * 
 * Init JECA, run main class
 */
void main( string[] args ) {
	args = args[ 0 ] ~ "-wxh 640 480".split ~ args[ 1 .. $ ]; //#Split isn't clear this way ("foo bar".split), I think. Less typing though
	
	auto ready = false;
	scope( exit ) { // try {} finally {}
		if ( ready )
			shutdown_input,
			writeln( "shutdown_input done" );
		else
			writeln( "Did not Init." );
	}
	
	someMixinsCalls( args );

	// JECA init
	immutable succeed = 0;
	if ( Init( args, ALLEGRO_INIT | TIMER | KEYBOARD | SOUND | GRAPHICS ) != succeed ) { // No mouse
		return;
	}
	
	ready = true;

	string[ ALLEGRO_COLOR ] colourLabel = [
		Colour.red: "Red",
		Colour.blue: "Blue"
	];
	
	//#doesn't draw strait onto bmp
	al_put_pixel( 1, 1, Colour.red );
	al_put_pixel( 2, 1, Colour.blue );
	
	ALLEGRO_BITMAP* bmp = al_get_backbuffer( DISPLAY );
	
	mixin( test( `colourLabel[ al_get_pixel( bmp, 1, 1 ) ] == "Red"`, `colour is red` ) );
	mixin( test( `colourLabel[ al_get_pixel( bmp, 2, 1 ) ] == "Blue"`, `colour is blue` ) );
	
	//#over engine eared, I think. But for practice.
	// loop through functions and calling them - font and display icon
	foreach( call; [ &setUpGlobalFont, &setUpIcon ] )
		*call;

	// create and launch main class object, then start main loop
	(new World).run;
}

/**
 * Some mixin calls using the arguments
 */
void someMixinsCalls( string[] args ) {
	mixin( trace( "args" ) );
	mixin( test( `algo.find( args[0], "abc5.exe" )`, `finds "abc5.exe"` ) );
}

/**
 * Make an array of fonts - the last one is set as the main one
 */
void setUpGlobalFont() {
//	g_fonts ~= al_load_font( "JJStencil solid.TTF", 36, 0 );
	g_fonts ~= al_load_font( "HARLOWSI.TTF", 36, 0 );
	g_fonts ~= al_load_font( "DejaVuSans.ttf", 36, 0); // 18 seemed nice, (but small)
	
	FONT = g_fonts[ $ - 1 ];
}

/**
 * Set icon for the window
 */
void setUpIcon() {
	al_set_display_icon( DISPLAY, loadBitmap( "abc.png" ) );
}
