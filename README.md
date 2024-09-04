# frame_skip_test

An app for detecting and debugging frame skips in Flutter.

NOTE: Most frame skips are also visible in the flutter devtools. Sometimes
the frame is skipped in lower levels of the stack though, without Flutter noticing.

## Usage

Build and run the app using flutter, and record the screen with a camera slow-motion mode.

The expected output is that on each frame, exactly one cell is filled (black -> white, or white -> black, depending on the chosen frame grid style).

In case there's a frame skip, you'll see more than one cell being filled in one frame.

### environment variables

#### `FRAME_GRID_STYLE`

- `black_to_white`: default
  - background is black, filled cells are white
  - had the faster response time in my limited testing
- `white_to_black`
  - background is white, filled cells are black

#### `ROUND_DISPLAY`

A value of `1` adds padding around the grid so all cells are visible on a round display.

### Example Usage

On macOS:
```shell
$ open build/macos/Build/Products/Release/frame_skip_test.app
# ...

$ FRAME_GRID_STYLE=white_to_black open build/macos/Build/Products/Release/frame_skip_test.app
# ...
```
