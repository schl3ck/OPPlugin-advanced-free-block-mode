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

[Setting name="Nudge mode for moving the block" category="Main" description="See help below for more information"]
SettingsNudgeMode settingNudgeModeTranslation = SettingsNudgeMode::Fixed;

[Setting name="Nudge mode for rotating the block" category="Main" description="See help below for more information"]
SettingsNudgeMode settingNudgeModeRotation = SettingsNudgeMode::Fixed;

[Setting name="Show help for nudge modes" category="Main"]
bool settingShowHelpForNudgeModes = false;

[Setting name="Show tooltip when the nudge direction of the last pressed key has changed" category="Main"]
bool settingShowTooltipOnNudgeModeNotify = true;

// this is written manually so it doesn't show up
bool settingFirstUse = true;

void OnSettingsLoad(Settings::Section& section) {
  settingFirstUse = section.GetBool("settingFirstUse", settingFirstUse);

  Keybindings::Deserialize(section.GetString("keybindings", "{}"));
}

void OnSettingsSave(Settings::Section& section) {
  section.SetBool("settingFirstUse", settingFirstUse);

  section.SetString("keybindings", Keybindings::Serialize());
}

void RenderSettings() {
  lastSettingsRendered = Time::get_Now();

  if (UI::Button("Reset to default")) {
    Keybindings::ResetAllKeys();
  }
  
  SettingKeyInfo@[] keyInfos;
  for (uint i = 0; i < Keybindings::names.Length; i++) {
    auto keyInfo = SettingKeyInfo(Keybindings::names[i]);
    keyInfo.renderKey();
    keyInfos.InsertLast(keyInfo);
  }
}

class SettingKeyInfo {
  string name;
  string displayName;

  SettingKeyInfo(string name) {
    this.name = name;
    displayName = Regex::Replace(name, "([a-z])([A-Z])", "$1 $2");
  }

  void renderKey() {
    printUITextOnButtonBaseline(
      displayName + ": \\$f90" + Keybindings::GetKeyString(name) + "\\$z "
    );
    if (CustomButton("Change", this.name)) {
      @settingKeyInfoWaitingForKey = this;
    }
    UI::SameLine();
    if (CustomButton("Unset", this.name)) {
      Keybindings::SetKey(name, VirtualKey(0));
    }
    UI::SameLine();
    if (CustomButton("Reset", this.name)) {
      Keybindings::ResetKey(name);
    }
    string description = Keybindings::GetKeyDescription(name);
    if (description.Length > 0) {
      UI::SameLine();
      UI::SetCursorPos(UI::GetCursorPos() + vec2(0, 4));
      UI::TextDisabled(Icons::QuestionCircle);
      if (UI::IsItemHovered()) {
        UI::BeginTooltip();
        UI::Text(description);
        UI::EndTooltip();
      }
    }
  }
}
