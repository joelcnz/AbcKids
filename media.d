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
import std.path;

import jeca.all;

import base, texthandling, progressbar;

// Media: sound and stuff
interface IMedia {
	@property IText text(); // key word
	@property ALLEGRO_BITMAP* picture(); // picture
	@property void devide( in bool devide0 ); // word/name devide setter 'cat, mouse' the ', ' is the thing
	void showRefWord( in g_PrintFatness printFatness ); // display word/name, done thick or thin
	void tell(); // play the sound, if one
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
	/**
	 * Helper function for the media class - loads media off HDD creating objects for the media
	 */
	static auto loadInMedia() {
		
		IMedia[] media;
		
		bool[string] oneEach;

		bool mediaLengthGreaterThanZero() {
			return media.length > 0;
		}
		
		//#didn't read the instructions properly, didn't see (SpanMode.shallow) single folder only (not use sub folders).
		string[] names;
		foreach(string e; dirEntries(g_playBackFolder, SpanMode.shallow)) {
			names ~= e;
		}

		// go through all the files setting them up
		g_progressBar = ProgressBar(
			/* step size: */ cast(float)DISPLAY_W / names.length,
			/* fullLength: */ DISPLAY_W);

		ALLEGRO_BITMAP* currentPicture;

		// Init
		with(g_progressBar)
			process(),
			draw();
		al_flip_display();
		foreach( name; names.sort ) {
			al_clear_to_color(Colour.black);
			with(g_progressBar)
				process(),
				draw();
			
			auto path = al_create_path(name.toStringz());
			scope( exit )
				al_destroy_path( path );

			alias al_get_path_extension getExtension;
			string 
				extension = getExtension(path).to!string().toLower(),
				fileNameBase;
			if ( name.isFile )
				fileNameBase = to!string( al_get_path_basename( path ) );
			else {
				writeln( "Ignore directory - ", name );
				continue;
			}

			//#was under debug
			writeln( format( "%s%s", fileNameBase, extension ) ); //#does not crash like writefln can
			
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
							g_playBackFolder ~ dirSeparator ~ fileNameBase,
							//filename,
						);
						//if (name.toLower.indexOf(".jpg") != -1)
						if (media[$ - 1].picture) {
							//al_draw_bitmap(media[$ - 1].picture, 0f, 25f, 0);
							currentPicture = media[$ - 1].picture;
						}
					}
				}

				if (currentPicture !is null)
					al_draw_bitmap(currentPicture, 0f, 25f, 0);
				
				//Update display
				al_flip_display();

				// If no matches for file (eg. 'shoe.mud' wouldn't be a match)
				auto notAMatch = ! aMatch;
				if ( notAMatch )
					writeln( "Reject: ", to!string( al_get_path_filename( path ) ) );
			}
		} // for Dir
		
		// Take off the devide text for the last referance word
		if ( mediaLengthGreaterThanZero )
			media[ $ - 1 ].devide = false;
		
		return media;
	}

	@property IText text() { return _text; }
	@property ALLEGRO_BITMAP* picture() { if ( _pic !is null ) return _pic(); else return null; } //#gotcha
	@property void devide( in bool devide0 ) { _devide = devide0; }

	this(
		IMedia[] media,
		ALLEGRO_COLOR fatColour,
		ALLEGRO_COLOR slimColour,
		string rootName
	) {
		debug(10)
			mixin("rootName".trace);
		
		string text = rootName[indexOf(rootName, dirSeparator) + 1 .. $].idup;
		_devide = true;
		real xpos = 0f, ypos = 0f;
		bool mediaLengthGreaterThanZero = media.length > 0;

		if (mediaLengthGreaterThanZero) {
			auto last = media[ $ - 1 ]; // prev - previous media object
			// last pos plus new word
			xpos = last.text.xpos + al_get_text_width( g_font, toStringz( last.text.stringText ~ g_devide) );
			ypos = last.text.ypos;
			//If would hang over the edge of the screen, then start new line for word etc
			if ( xpos + al_get_text_width( g_font, toStringz( text ~ g_devide ) ) > al_get_display_width( DISPLAY ) ) {
				xpos = 0f;
				ypos = ypos + al_get_font_line_height( g_font );
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
		
		foreach( ext; g_imageExtentions.split())
			if ( exists( rootName ~ ext ) ) {
				//al_set_new_bitmap_flags(ALLEGRO_MAG_LINEAR);
				_pic = new Bmp( (rootName ~ ext).checkFile(" image file loaded.") );
				break;
			}

		foreach( ext; g_soundExtentions.split())
			if ( exists( rootName ~ ext ) ) {
				_snd = al_load_sample( toStringz( (rootName ~ ext).checkFile(" sound file loaded.") ) );
				if ( _snd is null )
					writeln( rootName ~ ext ~ " warning sound failed!" );
				break;
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
		auto textAndDevide = _text.stringText ~ ( _devide == true ? g_devide : g_endOfList ) ;
		
		foreach( fatness; EnumMembers!g_PrintFatness )
			with( _text )
				_text.draw( xpos, ypos, fatness, textAndDevide );
	}
}
