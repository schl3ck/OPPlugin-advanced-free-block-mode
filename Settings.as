[Setting name="Show interface" category="Main"]
bool settingShowInterface = false;

[Setting name="Show coordinate system" category="Coordinate system"]
bool settingShowCoordinateSystem = false;

[Setting name="Scale" min=10 max=250 category="Coordinate system"]
int settingCoordinateSystemScale = 50;

[Setting name="Position of coordinate system and pivot position" category="Coordinate system"]
vec2 settingCoordinateSystemPosition = vec2(200, 200);

[Setting name="Move coordinate system" description="Use this to easily move the position." category="Coordinate system"]
bool settingMoveCoordinateSystem = false;

[Setting name="Show pivot position" category="Pivot position"]
bool settingShowPivotRenderer = false;

[Setting name="Position of rendered pivot position helper relative to the coordinate system" description="\"Center\" renders it on top of the coordinate system" category="Pivot position"]
PivotRendererPosition settingPivotRelativePosition = PivotRendererPosition::Center;

[Setting name="Scale" min=10 max=250 category="Pivot position"]
int settingPivotRendererScale = 50;

[Setting name="Display rotations in degrees (otherwise in radians)" category="Main"]
bool settingRotationInDeg = true;

[Setting name="Step size for position" category="Main"]
float settingStepSizePosition = 1.0;

[Setting name="Step size for rotation" category="Main"]
float settingStepSizeRotation = 15.0;

[Setting name="Nudge mode for moving the block" category="Main" description="Specifies which axis corresponds to which key. E.g. for the key Left: Fixed = X axis, RelativeToCamera = block moves left from your perspective, SelectedAxis = block moves along the selected axis."]
SettingsNudgeMode settingNudgeModeTranslation = SettingsNudgeMode::Fixed;

[Setting name="Nudge mode for rotating the block" category="Main" description="Specifies which axis corresponds to which key. E.g. for the key Left: Fixed = rotates around X axis, RelativeToCamera = block rolls left from your perspective, SelectedAxis = block rotates along the selected axis. NOTE: Sometimes in RelativeToCamera mode, especially on a 45° angle, the axis of rotation may switch while using the same key."]
SettingsNudgeMode settingNudgeModeRotation = SettingsNudgeMode::Fixed;

[Setting name="Show help for nudge modes" category="Main"]
bool settingShowHelpForNudgeModes = false;

[Setting name="Forward key" category="Keymap" description="Moves the block in the horizontal plane"]
VirtualKey settingKeyForward = VirtualKey::Up;
[Setting name="Backward key" category="Keymap" description="Moves the block in the horizontal plane"]
VirtualKey settingKeyBackward = VirtualKey::Down;
[Setting name="Left key" category="Keymap" description="Moves the block in the horizontal plane"]
VirtualKey settingKeyLeft = VirtualKey::Left;
[Setting name="Right key" category="Keymap" description="Moves the block in the horizontal plane"]
VirtualKey settingKeyRight = VirtualKey::Right;
[Setting name="Up key" category="Keymap" description="Moves the block on the vertical axis"]
VirtualKey settingKeyUp = VirtualKey::Prior;
[Setting name="Down key" category="Keymap" description="Moves the block on the vertical axis"]
VirtualKey settingKeyDown = VirtualKey::Next;
[Setting name="Toggle fixed cursor state" category="Keymap"]
VirtualKey settingKeyToggleFixedCursor = VirtualKey::N;
[Setting name="Toggle nudge mode" category="Keymap"]
VirtualKey settingKeyToggleNudgeMode = VirtualKey::L;
[Setting name="Toggle nudging relative to block orientation" category="Keymap"]
VirtualKey settingKeyToggleRelativNudging = VirtualKey::J;
[Setting name="Toggle refreshing of variables" category="Keymap"]
VirtualKey settingKeyToggleVariableUpdate = VirtualKey::T;
[Setting name="Cycle through the axis" category="Keymap" description="Only used in Nudge Mode 'SelectedAxis'"]
VirtualKey settingKeyCycleAxis = VirtualKey::B;

// this is written manually so it doesn't show up
bool settingFirstUse = true;

void OnSettingsLoad(Settings::Section& section) {
  settingFirstUse = section.GetBool("settingFirstUse", settingFirstUse);
}

void OnSettingsSave(Settings::Section& section) {
  section.SetBool("settingFirstUse", settingFirstUse);
}
