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
1. Place one block in free mode
1. Choose a block that _snaps_ to the previous block in roughly the same position where you want the new one
    * _Snapping_: when two blocks are similar and can connect they snap together at certain positions (e.g. tech road (1-1-1-1) snaps to itself in the direction of the road, sloped platform (5-2-2-2) snaps to the base platform (5-1-1-1))
1. While your mouse cursor is in the position where the blocks snapped together, press `T` to save the coordinates of the snapped block
1. Choose the block you want to place
1. Tick the box _Fix cursor position_. Your chosen block appears where the previous block snapped to the already placed block.
1. You can now nudge the block via the keys `I`, `K`, `J`, `L`, `B`, `N`
1. Toggle between moving the block and rotating it with `G`. Rotating uses the same keys
1. Switch between global and local axes with `O`
1. Place the block by clicking anywhere into the editor (like you place a block normally)
1. Disable _Fix cursor position_

### Note
The hotkeys only work if your mouse cursor is not over any interface of Openplanet. This is a limitation of Openplanet itself.
Also the block may flicker sometimes between the fixed position and your mouse cursor. This is normal because Trackmania isn't built that the to-be-placed block and your mouse cursor are not together. Just move your mouse some pixels or wait a bit until it stops again.

# How to install
Download it from https://openplanet.nl/files/109. You can also find a tutorial there how to install the plugin.

# Future plans
* Enable local rotation around other points than the origin of the block

# Changelog
v1.0 - 2021-07-24
Initial release
