# SepiaShell Wallpaper System — Phase 3 Plan (Search & Layout)

## Architecture Overview
Phase 3 focuses on layout adjustments, introducing real-time search, and implementing a double-click-to-apply feature while removing the dedicated "APPLY" button from the ConfigPanel (and eventually the ConfigPanel itself from this main view if it doesn't belong here, though the prompt implies moving search below the film strip and mentions "Apply(double click should apply so not extra buttons)", so I will adapt accordingly).

## Layout Adjustments
**New Vertical Hierarchy:**
1. **Preview Area**: Reduced in height by ~25-30%.
2. **Film Strip**: Maintains or slightly increases its prominence.
3. **Search Bar**: A new, hard-edged text input spanning the width, placed below the Film Strip.
4. **ConfigPanel (Settings)**: Placed at the very bottom (or adjusted as needed), with the "APPLY" button removed.

## Search & Filtering Strategy
**Component:** A standard QML `TextField` styled with SepiaShell aesthetics (hard edges, `#241D18` background, `#5A4736` border).

**Performance (Filtering without rescanning):**
- `FolderListModel` natively supports `nameFilters`. However, updating `nameFilters` dynamically for a real-time search triggers directory rescans, which hurts performance.
- **Solution**: We will introduce a QML `SortFilterProxyModel` (if available in Qt6) or manually proxy the data. Since standard QtQuick in Quickshell might not have `SortFilterProxyModel` exposed by default, an extremely robust alternative is to read the `FolderListModel` into a standard QML `ListModel` exactly once when `count` stabilizes, and then use Javascript to filter and populate a `filteredModel` in `WallpaperStore.qml`.
- **Match Rules**: Case-insensitive substring matching (`fileName.toLowerCase().includes(query.toLowerCase())`).
- **Empty Query**: Displays all items from the cached base model.

## Selection Handling & State
- When the `filteredModel` updates:
  - If the previously `selectedWallpaper` is no longer in the filtered list, `selectedIndex` will be reset to `0`, updating the `selectedWallpaper` and Preview Panel automatically.
  - If the filtered list is empty (`count === 0`), the Preview Panel will display "NO MATCHING WALLPAPERS".

## Double-Click Application
- The `FilmFrame` component will have an `onDoubleClicked` signal added to its `MouseArea`.
- In `FilmStrip.qml`, this will bubble up and call `store.applyWallpaper(index)`.
- The "APPLY" button in the `ConfigPanel` will be removed.

## Keyboard Navigation & Focus Strategy
- **Search Box Focused**: 
  - Left/Right arrows move the text cursor within the `TextInput`.
  - Esc clears the search or drops focus.
- **Search Box Not Focused (Main Window)**:
  - Left/Right arrows increment/decrement the `selectedIndex` in `WallpaperStore` (preparing for Phase 4).
  - The Main `Item` capturing global keys will use `Keys.forwardTo: [searchField]` or standard Focus Scope rules to ensure events route properly.

## Visual Style
- **Search Bar**: 
  - Background: `#241D18`
  - Border: `#5A4736` (2px, active focus changes to `#A67C52`)
  - Text: `#F2E0C8`
  - No rounded corners, no gradients.
- **Preview**: Maintained hard edges but smaller `Layout.preferredHeight`.

## Future Compatibility
By decoupling the view from a `filteredModel` inside `WallpaperStore.qml`, future extensions like sorting by date, filtering by favorites, or adding tags can be implemented entirely inside the store's Javascript logic without touching the UI components.
