bool fixCursorPosition = false;
bool refreshVariables = true;
vec3 cursorPosition = vec3();
float cursorYaw = 0;
float cursorPitch = 0;
float cursorRoll = 0;
bool localCoords = false;
NudgeMode nudgeMode = NudgeMode::Position;
PositionNudgeMode positionNudgeMode = PositionNudgeMode::GridSizeMultiple;
vec3 pivotPosition = vec3(0, 0, 0);
bool focusOnPivot = false;

float BiSlopeAngle = Math::ToDeg(Math::Atan(8.0f / 32.0f));
float Slope2Angle = Math::ToDeg(Math::Atan(16.0f / 32.0f));

// machine precision of floats. is probably smaller but this should suffice
float epsilon = 0.0001;

Resources::Font@ font = Resources::GetFont("DroidSans-Bold.ttf");
CoordinateSystem@ coordinateSystem = CoordinateSystem();
Pivot@ pivotRenderer = Pivot();
vec2 backgroundSize = vec2();
bool DrawAPIRemoved = false;

enum NudgeMode {
  Position,
  Rotation,
  Pivot
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

enum PivotRendererPosition {
  Top,
  Left,
  Center,
  Right,
  Bottom
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

    if (focusOnPivot) {
      FocusCameraOnPivot();
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

  backgroundSize = renderOverlayBackground();

  if (settingShowPivotRenderer) {
    vec2 pos = vec2(settingCoordinateSystemPosition);
    if (settingPivotRelativePosition == PivotRendererPosition::Right) {
      pos.x += coordinateSystem.size.x;
    }
    if (settingPivotRelativePosition == PivotRendererPosition::Bottom) {
      pos.y += coordinateSystem.size.y;
    }
    pivotRenderer.Render(
      pos,
      cursorYaw,
      cursorPitch,
      cursorRoll,
      renderCoordinateSystem,
      pivotPosition,
      getTileSize(pivotRenderer.size)
    );
  }

  renderCoordinateSystem(false);

  if (focusOnPivot && !DrawAPIRemoved && editor.Cursor.UseFreePos) {
    try {
      nvg::BeginPath();
      nvg::Circle(vec2(Draw::GetWidth(), Draw::GetHeight()) / 2, 3);
      nvg::FillColor(vec4(0, 0, 1, 1));
      nvg::Fill();
      nvg::StrokeWidth(2);
      nvg::StrokeColor(vec4(1, 0, 0, 1));
      nvg::Stroke();
    } catch {
      DrawAPIRemoved = true;
    }
  }
}
void renderCoordinateSystem(bool fromPivotRenderer) {
  if (!settingShowCoordinateSystem) return;
  if (
    fromPivotRenderer
    && settingPivotRelativePosition != PivotRendererPosition::Center
  )
    return;
  if (
    !fromPivotRenderer
    && settingPivotRelativePosition == PivotRendererPosition::Center
    && settingShowPivotRenderer
  )
    return;

  vec2 pos = vec2(settingCoordinateSystemPosition);
  if (settingPivotRelativePosition == PivotRendererPosition::Left) {
    pos.x += pivotRenderer.size.x;
  }
  if (settingPivotRelativePosition == PivotRendererPosition::Top) {
    pos.y += pivotRenderer.size.y;
  }
  coordinateSystem.Render(
    pos,
    localCoords,
    cursorYaw,
    cursorPitch,
    cursorRoll,
    getTileSize(coordinateSystem.size)
  );
}
vec2 renderOverlayBackground() {
  if (!settingShowCoordinateSystem && !settingShowPivotRenderer) return vec2();
  vec2 coordinateSize = coordinateSystem.size;
  vec2 pivotSize = pivotRenderer.size;
  vec2 size = vec2();
  if (!settingShowPivotRenderer) size = coordinateSize;
  else if (!settingShowCoordinateSystem) size = pivotSize;
  else {
    // both are displayed
    if (settingPivotRelativePosition == PivotRendererPosition::Top
      || settingPivotRelativePosition == PivotRendererPosition::Bottom) {
      size = vec2(
        Math::Max(coordinateSize.x, pivotSize.x),
        coordinateSize.y + pivotSize.y
      );
    } else if (settingPivotRelativePosition == PivotRendererPosition::Left
      || settingPivotRelativePosition == PivotRendererPosition::Right) {
      size = vec2(
        coordinateSize.x + pivotSize.x,
        Math::Max(coordinateSize.y, pivotSize.y)
      );
    } else {
      size = vec2(
        Math::Max(coordinateSize.x, pivotSize.x),
        Math::Max(coordinateSize.y, pivotSize.y)
      );
    }
  }
  
  nvg::BeginPath();
  nvg::FillColor(vec4(1, 1, 1, 0.2));
  nvg::RoundedRect(
    settingCoordinateSystemPosition.x,
    settingCoordinateSystemPosition.y,
    size.x,
    size.y,
    10
  );
  nvg::Fill();
  nvg::StrokeWidth(3);
  nvg::StrokeColor(vec4(1, 1, 1, 1));
  nvg::Stroke();

  return size;
}
vec2 getTileSize(vec2 ownSize) {
  if (settingPivotRelativePosition == PivotRendererPosition::Top
    || settingPivotRelativePosition == PivotRendererPosition::Bottom) {
    return vec2(backgroundSize.x, ownSize.y);
  } else if (settingPivotRelativePosition == PivotRendererPosition::Left
    || settingPivotRelativePosition == PivotRendererPosition::Right) {
    return vec2(ownSize.x, backgroundSize.y);
  } else {
    return backgroundSize;
  }
}

void RenderMenu() {
  CGameCtnEditorFree@ editor = GetMapEditor();
  if (UI::BeginMenu("\\$f90" + Icons::Gavel + "\\$z Advanced Free Block Mode")) {
    bool current = settingShowInterface
      && settingShowCoordinateSystem
      && settingShowPivotRenderer;
    if (UI::MenuItem(
      "Show/hide all",
      "",
      current,
      editor !is null
    )) {
      settingShowInterface = !current;
      settingShowCoordinateSystem = !current;
      settingShowPivotRenderer = !current;
    }

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

    if (UI::MenuItem(
      "Show pivot position",
      "",
      settingShowPivotRenderer,
      editor !is null
    )) {
      settingShowPivotRenderer = !settingShowPivotRenderer;
    }

    UI::EndMenu();
  }
}

void RenderInterface() {
  if (settingMoveCoordinateSystem) {
    UI::SetNextWindowPos(
      int(settingCoordinateSystemPosition.x),
      int(settingCoordinateSystemPosition.y)
    );
    UI::Begin(
      "\\$f90" + Icons::ExpandArrowsAlt + "\\$z Coordinate System",
      UI::WindowFlags::NoResize
      | UI::WindowFlags::NoCollapse
      | UI::WindowFlags::NoDocking
    );
    UI::SetWindowSize(
      vec2(Math::Max(backgroundSize.x, 100.), Math::Max(backgroundSize.y, 100.)),
      UI::Cond::Always
    );
    settingCoordinateSystemPosition = UI::GetWindowPos();

    // UI::Text("V " + Camera.m_CurrentVAngle); // pitch
    // UI::Text("H " + Camera.m_CurrentHAngle); // yaw

    UI::End();
  }

  CGameCtnEditorFree@ editor = GetMapEditor();
  if (editor is null) return;

  if (settingShowInterface) {
    UI::Begin(
      "\\$f90" + Icons::Gavel + "\\$z Advanced Free Block Mode",
      settingShowInterface,
      UI::WindowFlags::NoResize
    );
    UI::SetWindowSize(
      vec2(
        390,
        650 + (fixCursorPosition ? 90 : nudgeMode == NudgeMode::Pivot ? 5 : 0)
      ),
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

    if (nudgeMode == NudgeMode::Position || nudgeMode == NudgeMode::Rotation) {
      // ====================================== Fixed position
      UI::Text("Fixed position:");
      UI::Columns(3, "2", false);

      UI::Text("X");
      if (fixCursorPosition) {
        cursorPosition.x = UI::InputFloat("X", cursorPosition.x, 0);
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
    } else if (nudgeMode == NudgeMode::Pivot) {
      // ====================================== Pivot position
      UI::Text("Pivot position:");
      UI::Columns(3, "2", false);

      UI::Text("X");
      pivotPosition.x = UI::InputFloat("X", pivotPosition.x, 0);
      UI::Text("Nudge with\n\\$f90J\\$z & \\$f90L\\$z");
      UI::NextColumn();

      UI::Text("Y");
      pivotPosition.y = UI::InputFloat("Y", pivotPosition.y, 0);
      UI::Text("Nudge with\n\\$f90B\\$z & \\$f90N\\$z");
      UI::NextColumn();

      UI::Text("Z");
      pivotPosition.z = UI::InputFloat("Z", pivotPosition.z, 0);
      UI::Text("Nudge with\n\\$f90I\\$z & \\$f90K\\$z");
      UI::Columns(1, "3", false);
    }


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
    if (oldFixCursorPos != fixCursorPosition && !fixCursorPosition) {
      cursor.UseSnappedLoc = false;
    }

    UI::Text("Nudge ");
    UI::SameLine();
    bool checked;
    if (UI::Checkbox("Position", nudgeMode == NudgeMode::Position)) {
      nudgeMode = NudgeMode::Position;
    } else if (nudgeMode == NudgeMode::Position) {
      nudgeMode = NudgeMode::Rotation;
    }
    UI::SameLine();
    if (UI::Checkbox("Rotation", nudgeMode == NudgeMode::Rotation)) {
      nudgeMode = NudgeMode::Rotation;
    } else if (nudgeMode == NudgeMode::Rotation) {
      nudgeMode = NudgeMode::Position;
    }
    UI::SameLine();
    UI::TextDisabled("(Toggle with G)");

    if (UI::Checkbox("Nudge pivot point", nudgeMode == NudgeMode::Pivot)) {
      nudgeMode = NudgeMode::Pivot;
      localCoords = true;
    } else if (nudgeMode == NudgeMode::Pivot) {
      nudgeMode = NudgeMode::Rotation;
    }
    if (!VectorsEqual(pivotPosition, vec3(0, 0, 0))) {
      UI::SameLine();
      if (UI::Button("Reset")) {
        pivotPosition = vec3(0, 0, 0);
      }
      UI::SameLine();
      UI::TextDisabled(vecToString(pivotPosition, 3));
    }

    localCoords = UI::Checkbox("Nudge relative to block rotation", localCoords);
    UI::SameLine();
    UI::TextDisabled("(Toggle with O)");

    if (fixCursorPosition) {
      refreshVariables = false;
    }
    refreshVariables = UI::Checkbox(
      "Refresh position & rotation variables",
      refreshVariables
    );
    UI::SameLine();
    UI::TextDisabled("(Toggle with T)");

    if (!fixCursorPosition) {
      focusOnPivot = false;
    }
    focusOnPivot = UI::Checkbox("Focus camera on pivot", focusOnPivot);
    UI::SameLine();
    if(UI::Button("Focus once")) {
      FocusCameraOnPivot();
    }

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
        "Place the block by clicking anywhere after waiting for\n"
        + "it to be in the correct position if it flickers between the\n"
        + "fixed position and your mouse cursor"
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
  float stepSizeRad = Math::ToRad(settingStepSizeRotation);
  RotationAxis axis;
  float rotationDelta = 0;
  if (key == VirtualKey::J) {
    if (nudgeMode == NudgeMode::Position || nudgeMode == NudgeMode::Pivot) {
      move.x -= settingStepSizePosition 
        * (positionNudgeMode == PositionNudgeMode::GridSizeMultiple ? 32 : 1);
    } else {
      rotationDelta = -stepSizeRad;
      axis = RotationAxis::Roll;
    }
  } else if (key == VirtualKey::L) {
    if (nudgeMode == NudgeMode::Position || nudgeMode == NudgeMode::Pivot) {
      move.x += settingStepSizePosition 
        * (positionNudgeMode == PositionNudgeMode::GridSizeMultiple ? 32 : 1);
    } else {
      rotationDelta = stepSizeRad;
      axis = RotationAxis::Roll;
    }
  } else if (key == VirtualKey::I) {
    if (nudgeMode == NudgeMode::Position || nudgeMode == NudgeMode::Pivot) {
      move.z += settingStepSizePosition 
        * (positionNudgeMode == PositionNudgeMode::GridSizeMultiple ? 32 : 1);
    } else {
      rotationDelta = stepSizeRad;
      axis = RotationAxis::Pitch;
    }
  } else if (key == VirtualKey::K) {
    if (nudgeMode == NudgeMode::Position || nudgeMode == NudgeMode::Pivot) {
      move.z -= settingStepSizePosition 
        * (positionNudgeMode == PositionNudgeMode::GridSizeMultiple ? 32 : 1);
    } else {
      rotationDelta = -stepSizeRad;
      axis = RotationAxis::Pitch;
    }
  } else if (key == VirtualKey::B) {
    if (nudgeMode == NudgeMode::Position || nudgeMode == NudgeMode::Pivot) {
      move.y -= settingStepSizePosition 
        * (positionNudgeMode == PositionNudgeMode::GridSizeMultiple ? 8 : 1);
    } else {
      rotationDelta = -stepSizeRad;
      axis = RotationAxis::Yaw;
    }
  } else if (key == VirtualKey::N) {
    if (nudgeMode == NudgeMode::Position || nudgeMode == NudgeMode::Pivot) {
      move.y += settingStepSizePosition 
        * (positionNudgeMode == PositionNudgeMode::GridSizeMultiple ? 8 : 1);
    } else {
      rotationDelta = stepSizeRad;
      axis = RotationAxis::Yaw;
    }
  } else if (key == VirtualKey::G) {
    nudgeMode = 
      nudgeMode == NudgeMode::Position
      || nudgeMode == NudgeMode::Pivot
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
    if (nudgeMode == NudgeMode::Pivot) {
      pivotPosition += move;
    } else {
      if (localCoords) {
        move = rotateVec3(move, cursorYaw, cursorPitch, cursorRoll);
      }
      cursorPosition += move;
    }
    handled = true;
  } else if (rotationDelta > 0 || rotationDelta < 0) {
    cursorPosition += rotateVec3(
      pivotPosition,
      cursorYaw,
      cursorPitch,
      cursorRoll
    );
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
    cursorPosition -= rotateVec3(
      pivotPosition,
      cursorYaw,
      cursorPitch,
      cursorRoll
    );
    handled = true;
  }
  return handled;
}

void FocusCameraOnPivot() {
  CGameCtnEditorFree@ editor = GetMapEditor();
  if (editor is null) return;
  CGameControlCameraEditorOrbital@ camera = editor.OrbitalCameraControl;
  vec3 pivotOffset = rotateVec3(
      pivotPosition,
      cursorYaw,
      cursorPitch,
      cursorRoll
    );
  vec3 diff = cursorPosition + pivotOffset - camera.m_TargetedPosition;
  if (!VectorsEqual(diff, vec3(0, 0, 0))) {
    camera.m_TargetedPosition += diff;
    camera.Pos += diff;
  }
}
