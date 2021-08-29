## Help for nudge modes
In the settings for \$f90Advanced Free Block Mode\$z you can choose between different modes to map the key to an axis. The available modes are:
* Fixed
* RelativeToCamera
* SelectedAxis

Examples are given using the default key binding.
Rotations around an axis use the right-hand rule: When your extended thumb points in the direction of the axis, your fingers of your relaxed right hand curl in the direction of rotation (e.g. thumb points at your head, fingers curl around counter-clockwise)

### Fixed
In this mode each axis has its own key assigned:
* X-axis: \$f90Icons::LongArrowLeft\$z & \$f90Icons::LongArrowRight\$z
* Y-axis: \$f90PageIcons::LongArrowUp\$z & \$f90PageIcons::LongArrowDown\$z
* Z-axis: \$f90Icons::LongArrowUp\$z & \$f90Icons::LongArrowDown\$z
Movements are along the axis and rotations around it.

### RelativeToCamera
In this mode the keys are mapped to an axis depending on the camera's perspective:
* \$f90Icons::LongArrowLeft\$z: Moves the block to the left from the camera's perspective (axis in the horizontal plane preferred)
* \$f90Icons::LongArrowRight\$z: Moves the block to the right from the camera's perspective (axis in the horizontal plane preferred)
* \$f90Icons::LongArrowUp\$z: Moves the block forward (away) from the camera's perspective (axis in the horizontal plane preferred)
* \$f90Icons::LongArrowDown\$z: Moves the block backward (towards) from the camera's perspective (axis in the horizontal plane preferred)
* \$f90PageIcons::LongArrowUp\$z: Moves the block up from the camera's perspective (axis in the vertical plane preferred)
* \$f90PageIcons::LongArrowDown\$z: Moves the block down from the camera's perspective (axis in the vertical plane preferred)
Movements are along the axis and rotations are applied such that it rotates in the same direction as a car tire would when pushed that way (except the vertical axis, there it only rotates around the axis).

### SelectedAxis
In this mode you select a single axis by repeatedly pressing \$f90B\$z, then move or rotate the block along/around that axis by pressing \$f90Icons::LongArrowLeft\$z & \$f90Icons::LongArrowRight\$z.
