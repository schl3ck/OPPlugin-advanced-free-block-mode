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

// this is written manually so it doesn't show up
bool settingFirstUse = true;

void OnSettingsLoad(Settings::Section& section) {
  settingFirstUse = section.GetBool("settingFirstUse", settingFirstUse);
}

void OnSettingsSave(Settings::Section& section) {
  section.SetBool("settingFirstUse", settingFirstUse);
}
