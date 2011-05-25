/* To Dos:
 * More work on input.d [ ]
 * Add resize and save photos that are too big to fit in the display [ ]
 */
//#doesn't draw strait onto bmp
//#Split isn't clear this way ("foo bar".split), I think
//#over engine eared, I think. But for practice.
//#dlang.ogg is a funny one
/**
 * Type, Hear and See
 */
module type_hear_and_see;

version( Windows ) {
	pragma( lib, "liballegro5" );
	pragma( lib, "libdallegro5" );
	pragma( lib, "libjeca" );
}

version( linux ) {
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
import std.file;
import std.path;

import jeca.all;

import base, world;

/**
 * Learn more:
 * 
 * http://stackoverflow.com/questions/5630137/for-and-foreach-statements-in-d
 */
static this() {
	foreach( type; TypeTuple!( int, long, short, string ) ) {
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
	
	scope( exit ) { // try {} finally {}
		writeln( "Program exit" );
	}
	
	someMixinsCalls( args );

	// JECA init
	immutable succeed = 0;
	if ( Init( args, ALLEGRO_INIT | TIMER | KEYBOARD | SOUND | GRAPHICS ) != succeed ) { // No mouse
		return;
	}

	string[ ALLEGRO_COLOR ] colourLabel = [
		Colour.red: "Red",
		Colour.blue: "Blue",
		Colour.black: "Black"
	];
	
	//#doesn't draw strait onto bmp
	al_clear_to_color( Colour.black );
	al_put_pixel( 1, 0, Colour.red );
	al_put_pixel( 2, 0, Colour.blue );
	
	ALLEGRO_BITMAP* bmp = al_get_backbuffer( DISPLAY );
	
	mixin( test( `colourLabel[ al_get_pixel( bmp, 1, 0 ) ] == "Red"`, `colour is red` ) );
	mixin( test( `colourLabel[ al_get_pixel( bmp, 2, 0 ) ] == "Blue"`, `colour is blue` ) );
	
	mixin( test( `colourLabel[ al_get_pixel( bmp, 3, 0 ) ] == "Black"`, `background colour is black` ) );
	
	//#over engine eared, I think. But for practice.
	// loop through functions and calling them - font and display icon
	foreach( call; [ &setUpGlobalFont, &setUpIcon ] )
		*call;
	
	auto b = new Test( "mysha.pcx" );
	clear( b ); //#this is a problem, and the dumbest kind of crash (exiting though), doesn't seem to always happen though
	clear( b );
	writeln( "lets eat strawberries!" );

	// create and launch main class object, then start main loop
	try {
		(new World).run();
	} catch( Exception e ) {
		writeln( "Got to main: ", e.toString() );
	}
}

class Test {
	ALLEGRO_BITMAP* _bmp;
	string _name;
	
	this( string file ) {
		if ( exists( file ) ) {
			_name = file;
			_bmp = Bmp.loadBitmap( _name );
			writeln( _name, " loaded" );
		}
	}
	~this() {
		writeln( '"', _name, '"' ~ " deconstructor called {" ); // Name gets wiped out
		scope( exit )
			writeln( '}' );
		auto notNull = _bmp !is null;
		if ( notNull ) {
			al_destroy_bitmap( _bmp );
			writeln( "Bitmap destroyed." );
		} else {
			writeln( "Bitmap is already null." );
		}
	}
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
	g_font = al_load_font( "DejaVuSans.ttf", 36, 0); // 18 seemed nice, (but small)
}

/**
 * Set icon for the window
 */
void setUpIcon() {
	al_set_display_icon( DISPLAY, Bmp.loadBitmap( "abc.png" ) );
}
