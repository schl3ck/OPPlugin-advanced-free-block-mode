# Advanced Free Block Mode

> This is a plugin for OpenPlanet for the game Trackmania 2020.

A utility tool to place blocks pixel perfect in the free block mode.

# Features

* Nudge blocks precisely in every direction and rotation along/around the three main axes via hotkeys
* Either global axes (fixed to the world) or local axes (rotated with the block) can be used
* Freely choose the nudge distance
    * in multiples of the grid size (32x32x8) and without limitations
    * with presets for BiSlope and Slope2 inclinations
* Hide the block helpers at the block boundaries for better visibility if the to be placed block fits perfectly
* Move your mouse cursor freely without messing up the position of the block
* Optionally show a coordinate system to help you in finding the global or local axes

# How to use

1. Open the track editor and enable the interface in the scripts menu of Openplanet
2. Place one block in free mode
3. Choose a block that _snaps_ to the previous block in roughly the same position where you want the new one
    * _Snapping_: when two blocks are similar and can connect they snap together at certain positions (e.g. tech road (1-1-1-1) snaps to itself in the direction of the road, sloped platform (5-2-2-2) snaps to the base platform (5-1-1-1))
4. While your mouse cursor is in the position where the blocks snapped together, press `T` to save the coordinates of the snapped block
5. Choose the block you want to place
6. Tick the box _Fix cursor position_. Your chosen block appears where the previous block snapped to the already placed block.
    * You can now nudge the block via the keys `Left`, `Right`, `Up`, `Down`, `I`, `K`
    * Toggle between moving the block and rotating it with `L`. Rotating uses the same keys
    * Switch between global and local axes with `J`
    * Move the pivot point by selecting the checkbox _Nudge pivot point_. This moves the point around which the block is rotated
7. Place the block by clicking anywhere into the editor (like you place a block normally)
8. Disable _Fix cursor position_

### Note
The hotkeys only work if your mouse cursor is not over any interface of Openplanet. This is a limitation of Openplanet itself.  
Also the block may flicker sometimes between the fixed position and your mouse cursor. This is normal because Trackmania isn't built so that the to-be-placed block and your mouse cursor are not together. Just move your mouse some pixels or wait a bit until it stops again.

When rendering the coordinate system and block visualizer on top of each other, some lines may be on top of others when they shouldn't be.

# How to install
Download it from https://openplanet.nl/files/109. You can also find a tutorial there on how to install the plugin.

# Future plans
* Maybe support items. Unforunately I still haven't found a way to implement this.

# Contribute
You can find the source code for this plugin on [GitHub](https://github.com/schl3ck/OPPlugin-advanced-free-block-mode)

# Changelog
## v1.4.1 - 2023-01-12
* Performance improvements

## v1.4.0 - 2023-01-08
* Add point on screen to visualize the pivot point when in the correct editor mode
* Fix applying nudge distance twice
* Fix closing sections in the main window when switching nudge mode
* Use new scripting functionality in the settings window
* Improvements under the hood

## v1.3.3 - 2022-08-20
* Replace deprecated icon in the window that moves the coordinate system

## v1.3.2 - 2022-07-15
* Use new font loading system

## v1.3.1 - 2022-05-08
* Update callback functions to new signature

## v1.3.0 - 2022-02-20
* Add ability to use modifier keys for keyboard shortcuts
* Organize sections of UI into collapsing headers
* Fix empty strings as UI element id
* Fix swapped left & right arrow keys for fixedAxisPerKey mode
* Fix block visualizer not finding a block size
* Fix blocking arrow keys when block is not fixed
* Refactor keybindings for better internal structure (you shouldn't notice anything)
* Remove alpha on keybinding window

## v1.2.1 - 2021-09-06
* Fix plugin crash on start because of wrong path separator
* Tidy up interface
* Tidy up some code

## v1.2 - 2021-08-31
* Add new nudge mode where the axis is selected depending on the current camera yaw angle
* Add new nudge mode where the axis is selected by a key (like rotating in the mesh modeller)
* Add help for the different nudge modes
* Add ability to remap the keys
* Changed default keybinding
* Draw point on screen when fixing camera to pivot position
* Add button to reset pivot position
* Display pivot position in interface
* Fix incorrect display of block frame in block visualizer

## v1.1 - 2021-08-01
* Add ability to move the pivot point for rotations

## v1.0 - 2021-07-24
Initial release
