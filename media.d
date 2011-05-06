//#was under debug
//#does not crash like writefln can
//#why can't I put 'catch( AssertError a )' it prints 'AssertError'?
//#gotcha
import std.stdio;
import std.file; // checks to see if file exists
import std.string;
import std.conv: to;
import std.exception;
import std.traits: EnumMembers; // for foreach enums

import jeca.all;

import base, texthandling;

// Media: sound and stuff
interface IMedia {
	@property IText text(); // key word
	@property ALLEGRO_BITMAP* picture(); // picture
	@property void devide( in bool devide0 ); // word/name devide setter 'cat, mouse' the ', ' is the thing
	void showRefWord( in g_PrintFatness printFatness ); // display word/name, done thick or thin
	void tell(); // play the sound
}

/**
 * Title: Media class - word ref
 * 
 * Display words, pictures, and play sound
 */
class Media: IMedia {
private:
	Bmp _pic;
	ALLEGRO_SAMPLE* _snd;
	bool _devide;
	IText _text;
public:
	@property IText text() { return _text; }
	@property ALLEGRO_BITMAP* picture() { if ( _pic !is null ) return _pic(); else return null; } //#gotcha
	@property void devide( in bool devide0 ) { _devide = devide0; }

	this(
		IMedia[] media,
		ALLEGRO_COLOR fatColour,
		ALLEGRO_COLOR slimColour,
		string rootName
	) {
		debug
			mixin( trace( "rootName" ) );
		
		string text = rootName[ indexOf( rootName, `/` ) + 1 .. $ ].idup;
		_devide = true;
		real xpos = 0f, ypos = 0f;
		enum
			prev = media[ $ - 1 ], // prev - previous media object
			mediaLengthGreaterThanZero = media.length > 0;

		if ( mediaLengthGreaterThanZero ) {
			// last pos plus new word
			xpos = prev.text.xpos + al_get_text_width( FONT, toStringz( prev.text.stringText ~ g_devide) );
			ypos = prev.text.ypos;
			//If would hang over the edge of the screen, then start new line for word etc
			if ( xpos + al_get_text_width( FONT, toStringz( text ~ g_devide ) ) > al_get_display_width( DISPLAY ) ) {
				xpos = 0f;
				ypos = ypos + al_get_font_line_height( FONT );
			}
		}
		else {
			xpos = ypos = 0f;
		}
		
		_text = new Text(
			xpos,
			ypos,
			fatColour,
			slimColour,
			text
		);
		
		foreach( ext; split( g_imageExtentions ) )
			if ( exists( rootName ~ ext ) ) {
				_pic = new Bmp( rootName ~ ext );
				break;
			} 
		foreach( ext; split( g_soundExtentions ) ) {
			if ( exists( rootName ~ ext ) ) {
				_snd = al_load_sample( toStringz( rootName ~ ext ) );
				if ( _snd is null )
					writeln( rootName ~ ext ~ " warning sound failed!" );
				break;
			}
		}
	} // this

	/**
	 * Play sound if there's one
	 */
	void tell() {
		if ( _snd )
			al_play_sample(
				_snd,
				1.0,
				ALLEGRO_AUDIO_PAN_NONE,
				1.0,
				ALLEGRO_PLAYMODE.ALLEGRO_PLAYMODE_ONCE,
				null
			);
	}
	
	/**
	 * Show key word, gets call twice for drawing both thicknesses
	 */
	void showRefWord( in g_PrintFatness printFatness = g_PrintFatness.slim ) {
		// decides what to add to the end of the word, depending if it's the last word or not
		auto textDevide = _text.stringText ~ ( _devide == true ? g_devide : "" ) ;
		
		foreach( fatness; EnumMembers!g_PrintFatness )
			with( _text )
				_text.draw( xpos, ypos, fatness, textDevide );
	}
}

/**
 * Helper function for the media class - loads media off HDD creating objects for the media
 */
auto loadInMedia() {
	
	IMedia[] media;
	
	bool[string] oneEach;

	enum mediaLengthGreaterThanZero = media.length > 0;
	
	//#didn't read the instructions properly, didn't see (SpanMode.shallow) single folder only (not use sub folders).
	string[] names;
	foreach ( string e; dirEntries( g_playBackFolder, SpanMode.shallow) ) {
		names ~= e;
	}

	// go through all the files setting them up
	foreach( name; names.sort ) {
		auto path = al_create_path( toStringz( name ) );
		scope( exit )
			al_destroy_path( path );

		alias al_get_path_extension getExtension;
		string 
			extension = tolower( to!string( getExtension( path ) ) ),
			fileNameBase;
		if ( name.isFile )
			fileNameBase = to!string( al_get_path_basename( path ) );
		else {
			writeln( "Ignore directory - ", name );
			continue;
		}

		//#was under debug
		writeln( format( "%s%s", fileNameBase, extension ) ); //#does not crash like writefln can
		
		debug {
			writeln( "Is    right! ", g_playBackFolder ~ `/` ~ fileNameBase );
			writeln( "Is it right? " );
		}
		
		if ( fileNameBase !in oneEach ) {
			oneEach[ fileNameBase ] = true;
			auto aMatch = false;
			foreach( current; g_mediaExtentions.split ) {
				if ( extension == current ) {
					aMatch = true;
					media ~= new Media(
						media,
						Colour.red,
						Colour.yellow,
						g_playBackFolder ~ `/` ~ fileNameBase,
						//filename,
					);
				}
			}
			// If no matches for file (eg. 'shoe.mud' wouldn't be a match)
			enum notAMatch = ! aMatch;
			if ( notAMatch )
				writeln( "Reject: ", to!string( al_get_path_filename( path ) ) );
		}
	} // for Dir
	
	// Take off the devide text for the last referance word
	if ( mediaLengthGreaterThanZero )
		media[ $ - 1 ].devide = false;
	
	return media;
}
