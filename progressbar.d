module progressbar;

import jeca.all;

import base;

/**
 * Progress bar used when program is loading
 */
struct ProgressBar {
	float step; /// step size
	float fullLength; /// width of progress bar display
	float progress = 0f; // Current advance progress indicator
	
	/**
	 * Ctor
	 * para:increment size, width of bar display
	 */
	this(float step0, float fullLength0) {
		step = step0;
		fullLength = fullLength0;
	}

	/// update
	void process() {
		progress += step;
	}

	/// draw
	void draw() {
		al_draw_filled_rectangle(2,2, progress,20, Colour.amber);
		al_draw_rectangle(2,2, fullLength,20, Colour.yellow, 2);
	}
}
