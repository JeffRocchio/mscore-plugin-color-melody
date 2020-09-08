//=============================================================================
//  MuseScore
//  Music Composition & Notation
//
//  Color Melody-Line Notes Plugin
//
//  This plugin will make a naive attempt to color notes red to mark the
//  melody-line of the score. It simply assumes that the highest pitched
//  note is the melody note. To use it you do have to select one, or all,
//  of the measures on one staff. This is my first plugin so it certainly
//  is not sophisticated. While it is of use to me, my main goal here was
//  to gain some experience making a plugin. Please feel free to improve on
//  this.
//
//  Copyright (C) 2020 Jeffrey Rocchio
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2
//  as published by the Free Software Foundation and appearing in
//  the file LICENCE.GPL
//=============================================================================

import QtQuick 2.2
import MuseScore 3.0

MuseScore {
	version: "1.0.0"
	description: qsTr("Plugin that naively colors the melody line in a simple chord-melody arrangement. Simply assumes highest pitched note is the melody note.")
	menuPath: "Plugins.Notes." + qsTr("Color Melody Notes")

	property string red : "#aa0000"

	function colorNotes(notes) {
		var k = 0;
		var numNotes;
		var note = notes[0];
		numNotes = notes.length;
		//console.log("numNotes", numNotes);
		if (numNotes == 1) { // Single note, assume it is a melody note.
			if (typeof notes[0].tpc === "undefined") return;
			note = notes[0];
			//console.log("Pitch: ", notes[0].pitch);
			note.color = red;
			if (note.accidental) note.accidental.color = red;
			for (k = 0; k < note.dots.length; k++) {
				if (note.dots[k]) note.dots[k].color = red;
				}
		}  else { // Multi-note chord, assume highest pitched note is melody.
			if (typeof notes[0].tpc === "undefined") return;
			note = notes[numNotes-1]; // load highest pitch note.
			//console.log("Pitch: ", notes[0].pitch);
			note.color = red;
			if (note.accidental) note.accidental.color = red;
			for (k = 0; k < note.dots.length; k++) {
				if (note.dots[k]) note.dots[k].color = red;
			}
		} 
	}

	
	onRun: {
		var cursor = curScore.newCursor(); // Make a cursor object.
		var numNotes = 0;
		var endTick = 0;
		var notes;
		var sText = newElement(Element.STAFF_TEXT);

						// Determine if we have anything selected. If not, abort.
						//In this iteration I am requiring that the user make a
						//selection to avoid coloring an entire multi-part score
						//since I mostly use this function for complex scores.
		cursor.rewind(1)
		if (!cursor.segment) { 
						// no selection. Give a message then fall through to the
						//end, ending the plugin.
			console.log("No Selection. Select one, or all, measures to color.");

						//   Ok, we have something selected, color notes within
						//the selection.
		} else {
						// Get tick-number for end of the selection.
			cursor.rewind(2);
			if (cursor.tick === 0) {
						//   (This happens when the selection includes
						//the last measure of the score. rewind(2) goes 
						//behind the last segment (where there's none) 
						//and sets tick=0)
				endTick = curScore.lastSegment.tick + 1;
			} else {
				endTick = cursor.tick;
			}
			console.log("Selection Ends On Tick: ", endTick);
			cursor.rewind(1) //  Move cursor back to start of selection.
			while (cursor.segment && cursor.tick < endTick) {
				if (cursor.element.type === Element.CHORD) {
				notes = cursor.element.notes;
				numNotes = notes.length;
				//sText = newElement(Element.STAFF_TEXT);
				//sText.text = numNotes;
				//cursor.add(sText);
				colorNotes(notes);
				}
			cursor.next();  // Move to next segment.
			} // end while
		} // end top else stmt

		console.log("Plugin Exiting - presumed successful.");
		Qt.quit();
	} // end onRun

}
