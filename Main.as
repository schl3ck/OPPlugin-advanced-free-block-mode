[Setting name="Show interface"]
bool settingShowInterface = false;

[Setting name="Show helper coordinate system"]
bool settingShowCoordinateSystem = false;

[Setting name="Move helper coordinate system"]
vec2 settingCoordinateSystemPosition = vec2(200, 200);

[Setting name="Move helper coordinate system" description="Use this to easily move the position."]
bool settingMoveCoordinateSystem = false;

[Setting name="Display rotations in degrees (otherwise in radians)"]
bool settingRotationInDeg = true;

[Setting name="Step size for position"]
float settingStepSizePosition = 1.0;

[Setting name="Step size for rotation"]
float settingStepSizeRotation = 15.0;

// this is written manually so it doesn't show up
bool settingFirstUse = true;

bool fixCursorPosition = false;
bool refreshVariables = true;
vec3 cursorPosition = vec3();
float cursorYaw = 0;
float cursorPitch = 0;
float cursorRoll = 0;
bool localCoords = false;
NudgeMode nudgeMode = NudgeMode::Position;
PositionNudgeMode positionNudgeMode = PositionNudgeMode::GridSizeMultiple;

float BiSlopeAngle = Math::ToDeg(Math::Atan(8.0f / 32.0f));
float Slope2Angle = Math::ToDeg(Math::Atan(16.0f / 32.0f));

// machine precision of floats. is probably smaller but this should suffice
// when I make it smaller then there are sometimes problems in the function Angle
float epsilon = 0.0002;

Resources::Font@ font = Resources::GetFont("DroidSans-Bold.ttf");
CoordinateSystem@ coordinateSystem = CoordinateSystem();

enum NudgeMode {
  Position,
  Rotation
}

enum PositionNudgeMode {
  Simple,
  GridSizeMultiple
}

enum RotationAxis {
  Yaw,
  Pitch,
  Roll
}

void OnSettingsLoad(Settings::Section& section) {
  settingFirstUse = section.GetBool("settingFirstUse", settingFirstUse);
}

void OnSettingsSave(Settings::Section& section) {
  section.SetBool("settingFirstUse", settingFirstUse);
}

void Main() {
  if (!Permissions::OpenSimpleMapEditor()
      || !Permissions::OpenAdvancedMapEditor()
      || !Permissions::CreateLocalMap())
  {
      if (settingFirstUse)
        UI::ShowNotification(
          Icons::ExclamationCircle + "Advanced Free Block Mode",
          "Invalid permissions to run Advanced Free Block Mode plugin."
        );
      settingFirstUse = false;
      return;
  }
  settingFirstUse = false;

  while (true) {
    CGameCtnEditorFree@ editor = GetMapEditor();
    if (editor is null) {
      sleep(1000);
      continue;
    }

    if (fixCursorPosition) {
      editor.Cursor.UseSnappedLoc = true;
      editor.Cursor.SnappedLocInMap_Trans = cursorPosition;
      editor.Cursor.SnappedLocInMap_Yaw = cursorYaw;
      // seems like pitch & roll is swapped in the snapped pos
      editor.Cursor.SnappedLocInMap_Roll = cursorPitch;
      editor.Cursor.SnappedLocInMap_Pitch = cursorRoll;
      // yaw rotates around the editor y axis
      // roll rotates around the block z axis
      // pitch rotates around the block x axis
      // regardless of the angle, roll should turn around a block axis but
      // doesn't => should be swapped!
    } else if (refreshVariables) {
      cursorPosition = editor.Cursor.SnappedLocInMap_Trans;
      cursorYaw = editor.Cursor.SnappedLocInMap_Yaw;
      // seems like pitch & roll is swapped in the snapped pos
      cursorPitch = editor.Cursor.SnappedLocInMap_Roll;
      cursorRoll = editor.Cursor.SnappedLocInMap_Pitch;
    }

    sleep(10);
  }
}

void Render() {
  CGameCtnEditorFree@ editor = GetMapEditor();
  if (editor is null) return;
  // hide when openplanet is hidden
  if (!UI::IsOverlayShown()) {
    return;
  }

  if (settingShowCoordinateSystem)
    coordinateSystem.Render(localCoords, cursorYaw, cursorPitch, cursorRoll);
}

void RenderMenu() {
  CGameCtnEditorFree@ editor = GetMapEditor();
  if (UI::BeginMenu("\\$f90" + Icons::Gavel + "\\$z Advanced Free Block Mode")) {
    if (UI::MenuItem(
      "Show Interface",
      "",
      settingShowInterface,
      editor !is null
    )) {
      settingShowInterface = !settingShowInterface;
    }

    if (UI::MenuItem(
      "Show helper coordinate system",
      "",
      settingShowCoordinateSystem,
      editor !is null
    )) {
      settingShowCoordinateSystem = !settingShowCoordinateSystem;
    }

    UI::EndMenu();
  }
}

void RenderInterface() {
  coordinateSystem.RenderInterface();

  CGameCtnEditorFree@ editor = GetMapEditor();
  if (editor is null) return;

  if (settingShowInterface) {
    UI::Begin(
      "\\$f90" + Icons::Gavel + "\\$z Advanced Free Block Mode",
      settingShowInterface,
      UI::WindowFlags::NoResize
    );
    UI::SetWindowSize(
      vec2(370, 590 + (fixCursorPosition ? 75 : 0)),
      UI::Cond::Always
    );
    
    CGameCursorBlock@ cursor = editor.Cursor;

    UI::Text("Current position:");
    vec3 pos = cursor.FreePosInMap;
    UI::Columns(3, "0", false);
    UI::Text("X");
    UI::Text(Text::Format("%f", pos.x));
    UI::NextColumn();
    UI::Text("Y");
    UI::Text(Text::Format("%f", pos.y));
    UI::NextColumn();
    UI::Text("Z");
    UI::Text(Text::Format("%f", pos.z));
    UI::Columns(1, "1", false);


    UI::Separator();


    UI::Text("Fixed position:");
    UI::Columns(3, "2", false);

    UI::Text("X");
    if (fixCursorPosition) {
      cursorPosition.x = UI::InputFloat("X", cursorPosition.x, 0.);
    } else {
      UI::Text(Text::Format("%f", cursorPosition.x));
    }
    if (nudgeMode == NudgeMode::Position)
      UI::Text("Nudge with\n\\$f90J\\$z & \\$f90L\\$z");
    UI::NextColumn();

    UI::Text("Y");
    if (fixCursorPosition) {
      cursorPosition.y = UI::InputFloat("Y", cursorPosition.y, 0);
    } else {
      UI::Text(Text::Format("%f", cursorPosition.y));
    }
    if (nudgeMode == NudgeMode::Position)
      UI::Text("Nudge with\n\\$f90B\\$z & \\$f90N\\$z");
    UI::NextColumn();

    UI::Text("Z");
    if (fixCursorPosition) {
      cursorPosition.z = UI::InputFloat("Z", cursorPosition.z, 0);
    } else {
      UI::Text(Text::Format("%f", cursorPosition.z));
    }
    if (nudgeMode == NudgeMode::Position)
      UI::Text("Nudge with\n\\$f90I\\$z & \\$f90K\\$z");
    UI::Columns(1, "3", false);


    UI::Separator();


    UI::Text("Fixed rotation:");
    UI::SameLine();
    if(UI::Selectable(
      settingRotationInDeg ? "in degrees" : "in radians",
      false,
      UI::SelectableFlags::DontClosePopups
    )) {
      settingRotationInDeg = !settingRotationInDeg;
    }
    if (settingRotationInDeg) {
      cursorYaw = Math::ToDeg(cursorYaw);
      cursorPitch = Math::ToDeg(cursorPitch);
      cursorRoll = Math::ToDeg(cursorRoll);
    }

    UI::Columns(3, "4", false);

    UI::Text("X (Roll)");
    if (fixCursorPosition) {
      cursorRoll = UI::InputFloat("r", cursorRoll, 0);
    } else {
      UI::Text(Text::Format("%f", cursorRoll));
    }
    if (nudgeMode == NudgeMode::Rotation)
      UI::Text("Nudge with\n\\$f90J\\$z & \\$f90L\\$z");
    UI::NextColumn();

    UI::Text("Y (Yaw)");
    if (fixCursorPosition) {
      cursorYaw = UI::InputFloat("y", cursorYaw, 0);
    } else {
      UI::Text(Text::Format("%f", cursorYaw));
    }
    if (nudgeMode == NudgeMode::Rotation)
      UI::Text("Nudge with\n\\$f90B\\$z & \\$f90N\\$z");
    UI::NextColumn();

    UI::Text("Z (Pitch)");
    if (fixCursorPosition) {
      cursorPitch = UI::InputFloat("p", cursorPitch, 0);
    } else {
      UI::Text(Text::Format("%f", cursorPitch));
    }
    if (nudgeMode == NudgeMode::Rotation)
      UI::Text("Nudge with\n\\$f90I\\$z & \\$f90K\\$z");
    UI::Columns(1, "5", false);

    if (settingRotationInDeg) {
      cursorYaw = Math::ToRad(cursorYaw);
      cursorPitch = Math::ToRad(cursorPitch);
      cursorRoll = Math::ToRad(cursorRoll);
    }

    UI::Separator();

    bool oldFixCursorPos = fixCursorPosition;
    fixCursorPosition = UI::Checkbox("Fix cursor position", fixCursorPosition);
    if (fixCursorPosition) {
      refreshVariables = false;
    }
    if (oldFixCursorPos != fixCursorPosition && !fixCursorPosition) {
      cursor.UseSnappedLoc = false;
    }

    UI::Text("Nudge ");
    UI::SameLine();
    if (UI::Checkbox("Position", nudgeMode == NudgeMode::Position)) {
      nudgeMode = NudgeMode::Position;
    } else {
      nudgeMode = NudgeMode::Rotation;
    }
    UI::SameLine();
    if (UI::Checkbox("Rotation", nudgeMode == NudgeMode::Rotation)) {
      nudgeMode = NudgeMode::Rotation;
    } else {
      nudgeMode = NudgeMode::Position;
    }
    UI::SameLine();
    UI::TextDisabled("(Toggle with G)");

    localCoords = UI::Checkbox("Nudge relative to block rotation", localCoords);
    UI::SameLine();
    UI::TextDisabled("(Toggle with O)");

    refreshVariables = UI::Checkbox(
      "Refresh position & rotation variables",
      refreshVariables
    );
    UI::SameLine();
    UI::TextDisabled("(Toggle with T)");

    editor.HideBlockHelpers = UI::Checkbox(
      "Hide block helpers",
      editor.HideBlockHelpers
    );

    UI::Separator();

    UI::Text("Step size");
    if (UI::BeginCombo(
      " ",
      positionNudgeMode == PositionNudgeMode::Simple
        ? "Simple"
        : "Grid size multiple",
      UI::ComboFlags::PopupAlignLeft
    )) {
      if (UI::Selectable(
        "Simple",
        positionNudgeMode == PositionNudgeMode::Simple
      )) {
        positionNudgeMode = PositionNudgeMode::Simple;
      }
      if (UI::Selectable(
        "Grid size multiple",
        positionNudgeMode == PositionNudgeMode::GridSizeMultiple
      )) {
        positionNudgeMode = PositionNudgeMode::GridSizeMultiple;
      }
      UI::EndCombo();
    }
    settingStepSizePosition = UI::InputFloat(
      "Position" + (
        positionNudgeMode == PositionNudgeMode::GridSizeMultiple
          ? " * GS"
          : ""
        ),
      settingStepSizePosition,
      0.01f
    );

    if (UI::BeginCombo(
      "Rotation Presets",
      settingStepSizeRotation == BiSlopeAngle
        ? "BiSlope"
        : settingStepSizeRotation == Slope2Angle
        ? "Slope2"
        : "None",
      UI::ComboFlags::PopupAlignLeft
    )) {
      if (UI::Selectable("BiSlope", settingStepSizeRotation == BiSlopeAngle)) {
        settingStepSizeRotation = BiSlopeAngle;
      }
      if (UI::Selectable("Slope2", settingStepSizeRotation == Slope2Angle)) {
        settingStepSizeRotation = Slope2Angle;
      }
      UI::EndCombo();
    }
    settingStepSizeRotation = UI::InputFloat(
      "Rotation (deg)",
      settingStepSizeRotation,
      1.0f
    );

    if (fixCursorPosition) {
      UI::NewLine();
      UI::Text(
        "Place the block by clicking anywhere after waiting for\nit to be in the correct position"
      );
    }

    UI::End();
  }
}

bool OnKeyPress(bool down, VirtualKey key) {
  if (!settingShowInterface || !down)
    return false;
  CGameCtnEditorFree@ editor = GetMapEditor();
  if (editor is null)
    return false;

  bool handled = false;
  vec3 move = vec3();
  CGameCursorBlock@ cursor = editor.Cursor;
  float stepSizeRad = Math::ToRad(settingStepSizeRotation);
  RotationAxis axis;
  float rotationDelta = 0;
  if (key == VirtualKey::J) {
    if (nudgeMode == NudgeMode::Position) {
      move.x -= settingStepSizePosition 
        * (positionNudgeMode == PositionNudgeMode::GridSizeMultiple ? 32 : 1);
    } else {
      rotationDelta = -stepSizeRad;
      axis = RotationAxis::Roll;
    }
  } else if (key == VirtualKey::L) {
    if (nudgeMode == NudgeMode::Position) {
      move.x += settingStepSizePosition 
        * (positionNudgeMode == PositionNudgeMode::GridSizeMultiple ? 32 : 1);
    } else {
      rotationDelta = stepSizeRad;
      axis = RotationAxis::Roll;
    }
  } else if (key == VirtualKey::I) {
    if (nudgeMode == NudgeMode::Position) {
      move.z -= settingStepSizePosition 
        * (positionNudgeMode == PositionNudgeMode::GridSizeMultiple ? 32 : 1);
    } else {
      rotationDelta = stepSizeRad;
      axis = RotationAxis::Pitch;
    }
  } else if (key == VirtualKey::K) {
    if (nudgeMode == NudgeMode::Position) {
      move.z += settingStepSizePosition 
        * (positionNudgeMode == PositionNudgeMode::GridSizeMultiple ? 32 : 1);
    } else {
      rotationDelta = -stepSizeRad;
      axis = RotationAxis::Pitch;
    }
  } else if (key == VirtualKey::B) {
    if (nudgeMode == NudgeMode::Position) {
      move.y -= settingStepSizePosition 
        * (positionNudgeMode == PositionNudgeMode::GridSizeMultiple ? 8 : 1);
    } else {
      rotationDelta = -stepSizeRad;
      axis = RotationAxis::Yaw;
    }
  } else if (key == VirtualKey::N) {
    if (nudgeMode == NudgeMode::Position) {
      move.y += settingStepSizePosition 
        * (positionNudgeMode == PositionNudgeMode::GridSizeMultiple ? 8 : 1);
    } else {
      rotationDelta = stepSizeRad;
      axis = RotationAxis::Yaw;
    }
  } else if (key == VirtualKey::G) {
    nudgeMode = nudgeMode == NudgeMode::Position
      ? NudgeMode::Rotation
      : NudgeMode::Position;
    handled = true;
  } else if (key == VirtualKey::T) {
    refreshVariables = !refreshVariables;
    handled = true;
  } else if (key == VirtualKey::O) {
    localCoords = !localCoords;
  }

  if (move.Length() > 0) {
    if (localCoords) {
      move = rotateVec3(move, cursorYaw, cursorPitch, cursorRoll);
    }
    cursorPosition += move;
    handled = true;
  } else if (rotationDelta > 0 || rotationDelta < 0) {
    float[] res = rotateRotations(
      cursorYaw,
      cursorPitch,
      cursorRoll,
      rotationDelta,
      axis,
      localCoords
    );
    cursorYaw = res[0];
    cursorPitch = res[1];
    cursorRoll = res[2];
    handled = true;
  }
  return handled;
}

CGameCtnEditorFree@ GetMapEditor() {
  return cast<CGameCtnEditorFree>(GetApp().Editor);
}

vec3 vec4To3(vec4 v) {
  return vec3(v.x, v.y, v.z);
}

vec3 rotateVec3(vec3 v, float yaw, float pitch, float roll) {
  mat4 Ry = mat4::Rotate(yaw, vec3(0, 1, 0));
  mat4 Rz = mat4::Rotate(pitch, vec3(0, 0, 1));
  mat4 Rx = mat4::Rotate(roll, vec3(1, 0, 0));

  mat4 R = Ry * Rz * Rx;
  return vec4To3(R * v);
}

float[] rotateRotations(
  float yaw,
  float pitch,
  float roll,
  float delta,
  RotationAxis axis,
  bool local
) {
  // roll is local by definition
  if (local && axis == RotationAxis::Roll) return {yaw, pitch, roll + delta};
  // yaw is global by definition
  if (!local && axis == RotationAxis::Yaw) return {yaw + delta, pitch, roll};

  // base axes
  vec3 xAxis = vec3(1, 0, 0);
  vec3 yAxis = vec3(0, 1, 0);
  vec3 zAxis = vec3(0, 0, 1);

  // axes in current rotation
  vec3 x = rotateVec3(xAxis, yaw, pitch, roll);
  vec3 y = rotateVec3(yAxis, yaw, pitch, roll);
  vec3 z = rotateVec3(zAxis, yaw, pitch, roll);

  vec3 ax;
  if (local) {
    if (axis == RotationAxis::Yaw) ax = y;
    else if (axis == RotationAxis::Pitch) ax = z;
  } else {
    if (axis == RotationAxis::Pitch) ax = zAxis;
    else if (axis == RotationAxis::Roll) ax = xAxis;
  }

  // axes in wanted rotation
  mat4 m = mat4::Rotate(delta, ax);
  vec3 rX = vec4To3(m * x);
  vec3 rY = vec4To3(m * y);
  vec3 rZ = vec4To3(m * z);

  // project rX to xz plane
  vec3 rX_xz = vec3(rX.x, 0, rX.z);
  // yaw = angle between xAxis & projected vec
  float yaw2 = Angle(xAxis, rX_xz) * Sign(rX.z) * -1;
  // pitch = angle between projected vec & rotated vec
  float pitch2 = Angle(rX_xz, rX) * Sign(rX.y);

  m = mat4::Rotate(yaw2, yAxis);
  vec3 zYaw = vec4To3(m * zAxis);
  // roll = angle between zYaw & rZ
  float roll2 = Angle(zYaw, rZ) * Sign(rZ.y) * -1;

  return {yaw2, pitch2, roll2};
}

float Sign(float f) {
  return f < 0 ? -1. : 1.;
}

float Angle(vec3 a, vec3 b) {
  if (Math::Abs(a.x - b.x) <= epsilon
    && Math::Abs(a.y - b.y) <= epsilon
    && Math::Abs(a.z - b.z) <= epsilon
  )
    return 0;
  return Math::Acos(
    Math::Dot(a, b) / (a.Length() * b.Length())
  );
}
