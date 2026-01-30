# RESCODE ASSESSMENT – Flutter

**Author:** Sheriffdeen Ade'ola Olona

## Overview

This Flutter application demonstrates a scrollable, heterogeneous list of cards with real-time visibility detection. It implements programmatic scrolling and tracks the first and last visible items in the viewport using only Flutter’s native widgets and APIs.

## Features

* Heterogeneous List: Supports multiple card types (`small`, `medium`, `large`) with different heights.
* Scroll Position Tracking: Accurately detects the first and last visible list items on scroll.
* Programmatic Scrolling: Navigate to a specific item index via a dialog input.
* Visibility Indicators: Each visible item is visually highlighted.
* Performance: Efficiently calculates visible indices without unnecessary rebuilds.

## Implementation Details

* Uses a `ScrollController` to calculate which items are visible based on scroll offset and item heights.
* `ListView.builder` is used for efficient list rendering.
* `_updateVisibleIndices()` calculates visible indices by summing item heights and comparing against viewport boundaries.
* `_scrollToIndex(int index)` calculates the scroll offset for a target index and animates the scroll to bring it into view.
* Handles empty lists, out-of-range indices, and padding/margin offsets correctly.
* Follows Flutter best practices for readability, maintainability, and performance.

## Usage

1. Open a terminal or command prompt in your project folder.
2. Run the app: flutter run
3. Scroll the list to observe real-time updates of the first and last visible items.
4. Tap the **Go to Index** button to jump to a specific item.

## Technical Notes

* Only Flutter’s built-in widgets and APIs are used; no third-party packages.
* Code is structured for clarity, maintainability, and performance.