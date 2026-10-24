<!-- gf-brief source=9851bbdc85ed553cad740f9f8da5266a9f10814a34c4233e40edb50bfa3621f4 written=2026-10-24T21:44:03+03:00 -->
# BassDaunito

## What it is
BassDaunito is a reading log that treats one open book as an expedition on a map. You record pages you have read, and once the page pool is large enough you sight the next stop and the marker moves along the line. It is for someone who wants reading progress as stops, drift, and a page pool, kept on this device.

## Launch and onboarding
The app opens in dark mode under the name "BassDaunito". While the saved reading is still loading, the map is shown dimmed and cannot be tapped. If that wait lasts, a spinner appears over it. There is no other launch copy.

On a first launch, after that wait, a three-step intro replaces the map.

- The step counter reads "1" "of" "3". "Skip" is at the top. The picture is described as "A book drawn as a line of stops". The headline is "Log pages on a map." The line under it is "A book becomes a line of stops." The bottom button is "Next".
- Step "2" "of" "3". The picture is "Sighting the next stop". Headline "Sight the next stop." Detail "Twenty pages in the pool, then sight." Button "Next". "Skip" remains.
- Step "3" "of" "3". The picture is "Stops gathered on the map". Headline "Keep the gap honest." Detail "Logging ahead of the marker shows drift." The bottom button is "Start".

"Next" moves one step. "Start" and "Skip" leave the intro and open the map. While that save is in progress, "Next" and "Skip" do not respond again.

A later launch skips the intro and opens the map. An expedition that was still open is still open.

## Screens

### Map
This is the home screen. There is no tab bar. The small heading is "MAP", next to the local calendar day written as eight digits. The large line is "Log pages, then sight the next stop."

Five controls sit under that line. Each opens a full-height sheet:

- "Shelf" opens Shelf.
- "Session" opens Session.
- "Expedition" opens Expedition.
- "Pace" opens Pace.
- "Settings" opens Settings.

Every sheet has a drag indicator and a close control named "Close", which returns to the map.

When no expedition exists, the map shows a picture, then "No expedition yet." and "Open a book to start." The button "Open a book" starts the first shelf book and stays on the map.

When an expedition is underway, the map shows a status line, a page stepper, "Log", and "Sight". The status is "Log pages, then sight." while the pool is short, and the badge on the map reads "SHORT". The status is "Ready to sight." when the pool holds at least twenty pages, and the badge reads "READY". The stepper starts at 8. The minus control is named "Fewer pages" and the plus control is named "More pages". The number stays between 1 and 200. "Log" adds that many pages to the page pool and adds a row on Session. "Sight" is available only while the badge is "READY". Tapping it spends twenty pages, moves the marker to the next stop, and records a sight. If fewer than twenty pages remain, the badge returns to "SHORT". If that sight was the last stop, the map switches to the finished state.

The book title is a tappable chip that opens Shelf. Beside it, "Drift" shows an angle in degrees, "0°" until logged pages pull ahead of the marker, then a value with up to one decimal. "Page pool" shows the unspent pages as a number followed by "pages". A line labeled "AIM" shows a number with one decimal. Dragging the colored rule turns that aim. Dragging does not log pages or sight a stop.

When the last stop has been sighted, the map says "This expedition is finished.", shows the book title, and offers "Open a book". Drift and page pool remain under that. "Log" and "Sight" are not on this state.

If the saved reading cannot be opened, the note appears on the map with "Retry". The notes are "The saved chart could not be read. The table started blank.", "The chart file was unreadable. The previous chart was restored.", or "The chart file was unreadable. The table started blank."

### Shelf
The sheet title is "Shelf". A search field placeholder reads "Title or author". While the field has text, "Clear" empties it. The keyboard button is "Done".

Under "SHELF" are four books. Each row shows the title, the author, the page count, the word "pages", and either "Add" or "Open". "Open" means that book is the expedition already underway.

- "The Surveyor's Coast", "M. Hale", 240 pages.
- "Night Latitude", "I. Voss", 180 pages.
- "Paper Meridian", "C. Orth", 320 pages.
- "Glass Bearing", "A. Quinn", 160 pages.

Tapping a row starts that book as the expedition and closes Shelf. Stops are named "Station 1", "Station 2", and so on, one stop for every twenty pages, and at least one stop. "The Surveyor's Coast" has twelve stops, "Night Latitude" nine, "Paper Meridian" sixteen, and "Glass Bearing" eight.

If the search matches nothing, the list is replaced by "No book matches." and "Clear the search and try another title."

"Add a book" opens fields "Title", "Author", and "Pages". The button becomes "Hide new book", which closes those fields. "Add book" creates that book as the new expedition and closes Shelf. It stays disabled until the title is filled and Pages is a whole number above zero. A blank author is stored without a name on this sheet. A book you type does not stay in the shelf list; it lives as the open expedition.

### Session
The sheet title is "Session". The heading is "Log pages, then sight." If nothing is open, the status explains the next step and the button is "Open a book", which starts "The Surveyor's Coast" and closes the sheet.

If an expedition exists, a field labeled "PAGES" accepts a page count. It starts at 8. The keyboard button is "Done". "Log" adds that count to the open expedition. The status is "Twenty pages, then sight on the map." while the pool is short, and "Ready to sight." when it is not. Sighting stays on the map.

Logged rows show the book title, the date and time, and the page count, newest first. Before any row exists, the sheet says "No pages logged yet."

### Expedition
The sheet title is "Expedition". With no expedition at all, it says "No expedition yet." and "Open a book to lay the stops.", with "Open a book".

Otherwise it shows the book title, or "Open book" if the title is missing. After at least one page is logged, it shows the drift as a number and the words "degrees of drift". A line reads like "0 of 12 stops sighted. 0 pages logged." The counts follow the open book.

Under "STOPS", each stop shows its name, "Page" and the page milestone (20, 40, 60, and so on, never past the book's page count), and one of "Sighted", "Next", or "Ahead".

Under "SIGHTS", each sight shows the date and time and a bearing in degrees. The list appears only after the first sight.

While the pool is short and the expedition is still open, "Pages to log" offers "Fewer", the count as a number plus "pages", and "More". The count starts at 8 and stays between 1 and 200. The bottom button then reads "Log" plus that count and the word "pages", and it logs those pages.

When the pool is ready, the bottom button is "Sight the next stop". It sights from this sheet and spends twenty pages.

When the expedition is finished, every stop reads "Sighted" and the bottom button is "Open a book".

### Pace
The sheet title is "Pace". With no expeditions, it says "No pace yet." and "Open a book and log pages.", with "Open a book".

Otherwise the heading is "Reading pace", then "Pages logged" with a number and "pages", "Sights taken" with a number and "sights", and "Expeditions finished" with a number and "expeditions".

Under "FINISHED EXPEDITIONS", each finished book shows its title, or "Finished book", then a number, "sights,", a number, and "pages". If none are finished, it says "None finished yet. The open book is still on the map."

If a book is still open, a line names it and says it "is still open. Continue it from the map." The bottom button is "Continue the expedition", which closes Pace and returns to the map. If every expedition is finished, the line is "Every expedition on this device is finished. Open another book." and the button is "Open a book".

The same unreadable-chart note can appear here with "Retry".

### Settings
The sheet title is "Settings".

With no expeditions, the first block says "Nothing stored yet." After at least one expedition, the block "ON THIS DEVICE" shows "Pages logged" and "Books", each with a number. "Books" counts books that have been opened or added, not the four shelf titles waiting unused.

"AIM" holds the switch "Whole degrees". Off, expedition drift and sight bearings keep one decimal. On, those numbers are whole degrees. The aim rule on the map still shows one decimal.

"Show intro again" returns to the three-step intro. The open expedition and the logs stay.

"Delete all data" asks "Delete every expedition on this device?" The choices are "Delete all data" and "Cancel". Confirming removes every expedition, book, and log, then returns to the intro. The four shelf titles are still there afterward.

"Contact" opens the support page. Under it, the sheet says "Everything stays on this device."

If the saved reading could not be read, a block titled "COULD NOT READ" shows the same note as the map and a "Retry" button.

## Features
- "Log pages on a map" for one open book at a time.
- A "Page pool" that must reach twenty pages before "Sight".
- "Sight" spends twenty pages and moves the marker to the next stop.
- "Drift" when logged pages run ahead of the marker.
- An "AIM" rule you can drag on the map.
- "Shelf" search across the four built-in books, plus "Add a book".
- "Session" history of every logged page count.
- "Expedition" stops marked "Sighted", "Next", and "Ahead", plus "SIGHTS".
- "Pace" for "Pages logged", "Sights taken", and "Expeditions finished".
- "Whole degrees" for the expedition readout.
- "Show intro again".
- "Delete all data".
- "Contact".

## Behaviours that can look like bugs
- "Sight" does nothing until the page pool reaches twenty. The badge reads "SHORT" and the status is "Log pages, then sight." Log pages with "Log", in batches from 1 to 200, until the status becomes "Ready to sight." and the badge reads "READY". The starting stepper value is 8, so three logs of 8 reach 24.
- On the map, "Log" is disabled while the status is "Ready to sight." Sight first. "Sight" then spends twenty pages. If the pool drops under twenty, "Log" works again and "Sight" does not. That alternation is the loop.
- "Fewer pages" and "More" stop at 1 and 200 with no message.
- A second book will not start while one expedition is unfinished. The map says "A book is already open. Finish it first." On Shelf, tapping "Add" or "Open" then stays on the sheet. Finish the last stop, or use "Delete all data", then open another book.
- "Open a book" on an empty map, Session, Expedition, or Pace always starts "The Surveyor's Coast", not a book you pick. Pick a different title from "Shelf".
- "Add book" stays disabled until "Title" is filled and "Pages" is a whole number above zero. A decimal, a minus, or an empty field shows "Enter a whole number above zero." A title with no usable page count shows "Add a title and a page count above zero."
- "Pages" is not limited to the book's length. You can log past the last page. The stop list still ends at the book's page count.
- On a finished expedition, Session can still say "Twenty pages, then sight on the map." while "Log" is disabled. The map says "This expedition is finished." Open another book from the map or from Shelf.
- Shelf search with no match shows "No book matches." Tap "Clear" or change the text. A book you added by typing is not listed on the shelf afterward. It is the open expedition.
- "Show intro again" plays the intro and then returns to the same unfinished expedition. It is not a reset.
- "Nothing stored yet.", "No expedition yet.", "No pace yet.", and "No pages logged yet." are the empty screens before the first book or the first log.
- If the saved reading cannot be read, the map can say the table "started blank" or that "The previous chart was restored." "Retry" reads it again. "Delete all data" clears it on purpose.

Other lines that can appear when an action is refused: "Open a book first.", "This expedition is finished.", and "That book is missing."

## Starter content and resume
The shelf always offers "The Surveyor's Coast", "Night Latitude", "Paper Meridian", and "Glass Bearing". A new install has no open expedition and no logged pages.

An unfinished expedition resumes on the next launch, including the page pool, stops, sights, and session rows. "Show intro again" keeps that work. "Delete all data" does not.

## Permissions
None.

## Absent
Login or accounts, in-app purchase, ads, analytics, user-generated content shared with anyone else, an account deletion flow, and an App Tracking Transparency prompt are all absent. "Delete all data" erases the reading stored on this device. It is not an account.

## Data and support
Reading logs, books you add, and the intro flag stay on this device. Settings says "Everything stays on this device." "Contact" opens the support page.

## Scanning and health
None.

## Platform
Numbers and dates follow the device language and calendar. There is no separate region edition. The interface is dark on iPhone and iPad. iPhone uses portrait, landscape left, and landscape right, and the app stays full screen. iPad also uses upside down. The minimum system version is iOS 17.0.

## Category
Books.
