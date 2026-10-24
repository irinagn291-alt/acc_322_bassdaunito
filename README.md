# Alidade

Alidade is a reading expedition on a plane table. A reader logs pages into a charge pool, then sights the next station so the figure advances along the route of the open volume.

The domain is a fold, not a list of records. `TableFold` reduces sortie events into one presence: Blank when nothing is open, Slack while charge is under 20 pages, Charged once charge reaches that sight cost, and Arrived when the last station is sighted. Open from the catalogue writes a sortie at Datum in Slack with charge at zero. A second open while a sortie is underway is refused. Sight on Slack writes an EarlyMark and does not move the figure. Sight on Charged writes a SightMark, spends 20 pages, and advances one station.

That fold is the product. The map will draw the figure and the drift angle from it. Drift is `(last end page / total − progress) × 45°`. Route position is cumulative logged pages divided by the volume length. Logging ahead of the figure creates drift. Sighting spends charge and catches the figure up.

Persistence is one `TableArchive` under `ald.table.archive.v1`, written atomically to Application Support and mirrored to UserDefaults. The board holds the chart in memory. The file is a projection of that chart, saved after a short debounce and flushed when the scene leaves the foreground. A corrupt file falls back to the previous copy, then to a blank table.

There are no third-party packages. The chart stays on device.

The reason to pick Alidade is the log-then-sight fold. Logging fills a pool. At 20 pages the expedition is charged and Sight is the next tap. Sight spends those 20 pages, writes a mark, and moves one stop. Sighting too early records the attempt and does not move. A second book cannot open while one is underway.

The map is a UIKit shell: one `UIHostingController` inside the window scene. The terrain shader and the sight burst live only on that map. Shelf, session, expedition, pace, and settings are sheets.

Simulator launches seed `ald.demo.v1` with onboarding already complete and a charged book, so Sight is live. A device does not receive that seed.

Art style: soft 3D clay icons, photography-driven. The factory fills these empty image sets later:

- `ald_Onboarding1`: Soft 3D clay icons with tactile matte studio lighting, sculpted surveyor instruments and miniature topographic landforms with crisp cutout alpha silhouettes and subtle photographic surface grain., a person or object that is this product in one glance
- `ald_Onboarding2`: the same base, the primary action of this product, mid-gesture
- `ald_Onboarding3`: the same base, a later moment when the product has accumulated meaning
- `ald_EmptyHome`: the same base, a solid closed bowl, crate or folded cloth waiting to be used
- `ald_TwistHero`: the same base, an emblem of log-then-sight
- `ald_EmptyTableClay`: sculpted soft 3D clay plane-table tripod with a brass-style alidade rule resting on a folded survey map sheet
- `ald_FigureMarkerClay`: miniature soft 3D clay surveyor range pole and sighting plumbline figure on a bevelled terrain plinth

This is not a shelf you rate, and not a drift curl, lock chain, contour, rhumb, reef, canal, or mortar log. Progress is a fold on a map.

Build from this folder:

```
xcodegen generate
xcodebuild -scheme Alidade -destination 'generic/platform=iOS' build
```
