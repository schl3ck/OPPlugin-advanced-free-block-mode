## Help for nudge modes
In the settings for **Advanced Free Block Mode** you can choose between different modes to map the key to an axis. The available modes are:
* Fixed
* RelativeToCamera
* SelectedAxis

Examples are given using the default key binding.
Rotations around an axis use the right-hand rule: When your extended thumb points in the direction of the axis, your fingers of your relaxed right hand curl in the direction of rotation (e.g. thumb points at your head, fingers curl around counter-clockwise)

### Fixed
In this mode each axis has its own key assigned:
* X-axis: _Icons::LongArrowLeft_ & _Icons::LongArrowRight_
* Y-axis: _PageIcons::LongArrowUp_ & _PageIcons::LongArrowDown_
* Z-axis: _Icons::LongArrowUp_ & _Icons::LongArrowDown_
Movements are along the axis and rotations around it.

### RelativeToCamera
In this mode the keys are mapped to an axis depending on the camera's perspective:
* _Icons::LongArrowLeft_: Moves the block to the left from the camera's perspective (axis in the horizontal plane preferred)
* _Icons::LongArrowRight_: Moves the block to the right from the camera's perspective (axis in the horizontal plane preferred)
* _Icons::LongArrowUp_: Moves the block forward (away) from the camera's perspective (axis in the horizontal plane preferred)
* _Icons::LongArrowDown_: Moves the block backward (towards) from the camera's perspective (axis in the horizontal plane preferred)
* _PageIcons::LongArrowUp_: Moves the block up from the camera's perspective (axis in the vertical plane preferred)
* _PageIcons::LongArrowDown_: Moves the block down from the camera's perspective (axis in the vertical plane preferred)
Movements are along the axis and rotations are applied such that it rotates in the same direction as a car tire would when pushed that way (except the vertical axis, there it only rotates around the axis).

### SelectedAxis
In this mode you select a single axis by repeatedly pressing _B_, then move or rotate the block along/around that axis by pressing _Icons::LongArrowLeft_ & _Icons::LongArrowRight_.
