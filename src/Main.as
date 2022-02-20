bool fixCursorPosition = false;
bool refreshVariables = true;
vec3 cursorPosition = vec3();
float cursorYaw = 0;
float cursorPitch = 0;
float cursorRoll = 0;
float blockPitch = 0;
float blockRoll = 0;
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
BlockVisualizer@ blockVisualizer = BlockVisualizer();
vec2 backgroundSize = vec2();

VirtualKey nullKey = VirtualKey(0);
uint64 notifyNudgeKeyChange = 0;

string nudgeModeHelpText;
SettingKeyInfo@ settingKeyInfoWaitingForKey;
uint64 lastSettingsRendered = 0;

enum NudgeMode {
  Position,
  Rotation,
  Pivot
};

enum SettingsNudgeMode {
  Fixed,
  RelativeToCamera,
  SelectedAxis
};

enum PositionNudgeMode {
  Simple,
  GridSizeMultiple
};

enum BlockVisualizerPosition {
  Top,
  Left,
  Center,
  Right,
  Bottom
};

funcdef VirtualKey[] VectorToKeyFunc(vec3 vector);
funcdef vec3 KeyToVectorFunc(const VirtualKey[] &in key);

dictionary KeyToIconMap = {
  { "Up", Icons::LongArrowUp },
  { "Down", Icons::LongArrowDown },
  { "Left", Icons::LongArrowLeft },
  { "Right", Icons::LongArrowRight },
  { "Prior", "Page" + Icons::LongArrowUp },
  { "Next", "Page" + Icons::LongArrowDown },
  { "Control", "Ctrl" },
  { "Menu", "Alt" }
};

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

  nudgeModeHelpText = replaceIcons(readPluginFile("src/NudgeModes/nudgeModeHelp.md"));

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

      // fix normal block rotations to enable using the arrow keys
      editor.Cursor.Pitch = blockPitch;
      editor.Cursor.Roll = blockRoll;
    } else if (refreshVariables) {
      cursorPosition = editor.Cursor.SnappedLocInMap_Trans;
      cursorYaw = editor.Cursor.SnappedLocInMap_Yaw;
      // seems like pitch & roll is swapped in the snapped pos
      cursorPitch = editor.Cursor.SnappedLocInMap_Roll;
      cursorRoll = editor.Cursor.SnappedLocInMap_Pitch;

      // fix normal block rotations to enable using the arrow keys
      blockPitch = editor.Cursor.Pitch;
      blockRoll = editor.Cursor.Roll;
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

  if (settingShowBlockVisualizer) {
    vec2 pos = vec2(settingCoordinateSystemPosition);
    if (settingBlockVisualizerRelativePosition == BlockVisualizerPosition::Right) {
      pos.x += coordinateSystem.size.x;
    }
    if (settingBlockVisualizerRelativePosition == BlockVisualizerPosition::Bottom) {
      pos.y += coordinateSystem.size.y;
    }
    blockVisualizer.Render(
      pos,
      cursorYaw,
      cursorPitch,
      cursorRoll,
      renderCoordinateSystem,
      pivotPosition,
      getTileSize(blockVisualizer.size)
    );
  }

  renderCoordinateSystem(false);

  if (focusOnPivot && editor.Cursor.UseFreePos) {
    nvg::BeginPath();
    nvg::Circle(vec2(Draw::GetWidth(), Draw::GetHeight()) / 2, 3);
    nvg::FillColor(vec4(0, 0, 1, 1));
    nvg::Fill();
    nvg::StrokeWidth(2);
    nvg::StrokeColor(vec4(1, 0, 0, 1));
    nvg::Stroke();
  }
}
void renderCoordinateSystem(bool fromBlockVisualizer) {
  if (!settingShowCoordinateSystem) return;
  if (
    fromBlockVisualizer
    && settingBlockVisualizerRelativePosition != BlockVisualizerPosition::Center
  )
    return;
  if (
    !fromBlockVisualizer
    && settingBlockVisualizerRelativePosition == BlockVisualizerPosition::Center
    && settingShowBlockVisualizer
  )
    return;

  vec2 pos = vec2(settingCoordinateSystemPosition);
  if (settingBlockVisualizerRelativePosition == BlockVisualizerPosition::Left) {
    pos.x += blockVisualizer.size.x;
  }
  if (settingBlockVisualizerRelativePosition == BlockVisualizerPosition::Top) {
    pos.y += blockVisualizer.size.y;
  }
  coordinateSystem.Render(
    pos,
    localCoords,
    cursorYaw,
    cursorPitch,
    cursorRoll,
    getTileSize(coordinateSystem.size),
    (
      nudgeMode == NudgeMode::Rotation
      ? settingNudgeModeRotation
      : settingNudgeModeTranslation
    ) == SettingsNudgeMode::SelectedAxis
      ? NudgingSelectedAxis::nudgeAxes[NudgingSelectedAxis::nudgeAxisIndex]
      : vec3()
  );
}
vec2 renderOverlayBackground() {
  if (!settingShowCoordinateSystem && !settingShowBlockVisualizer) return vec2();
  vec2 coordinateSize = coordinateSystem.size;
  vec2 blockVisualizerSize = blockVisualizer.size;
  vec2 size = vec2();
  if (!settingShowBlockVisualizer) size = coordinateSize;
  else if (!settingShowCoordinateSystem) size = blockVisualizerSize;
  else {
    // both are displayed
    if (settingBlockVisualizerRelativePosition == BlockVisualizerPosition::Top
      || settingBlockVisualizerRelativePosition == BlockVisualizerPosition::Bottom) {
      size = vec2(
        Math::Max(coordinateSize.x, blockVisualizerSize.x),
        coordinateSize.y + blockVisualizerSize.y
      );
    } else if (settingBlockVisualizerRelativePosition == BlockVisualizerPosition::Left
      || settingBlockVisualizerRelativePosition == BlockVisualizerPosition::Right) {
      size = vec2(
        coordinateSize.x + blockVisualizerSize.x,
        Math::Max(coordinateSize.y, blockVisualizerSize.y)
      );
    } else {
      size = vec2(
        Math::Max(coordinateSize.x, blockVisualizerSize.x),
        Math::Max(coordinateSize.y, blockVisualizerSize.y)
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
  if (settingBlockVisualizerRelativePosition == BlockVisualizerPosition::Top
    || settingBlockVisualizerRelativePosition == BlockVisualizerPosition::Bottom) {
    return vec2(backgroundSize.x, ownSize.y);
  } else if (settingBlockVisualizerRelativePosition == BlockVisualizerPosition::Left
    || settingBlockVisualizerRelativePosition == BlockVisualizerPosition::Right) {
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
      && settingShowBlockVisualizer;
    if (UI::MenuItem(
      "Show/hide all",
      "",
      current,
      editor !is null
    )) {
      ModifierKeys::Reset();
      settingShowInterface = !current;
      settingShowCoordinateSystem = !current;
      settingShowBlockVisualizer = !current;
    }

    if (UI::MenuItem(
      "Show Interface",
      "",
      settingShowInterface,
      editor !is null
    )) {
      ModifierKeys::Reset();
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
      "Show block visualizer",
      "",
      settingShowBlockVisualizer,
      editor !is null
    )) {
      settingShowBlockVisualizer = !settingShowBlockVisualizer;
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

  if (settingShowHelpForNudgeModes) {
    UI::Begin(
      "\\$f90" + Icons::Gavel + "\\$z Nudge mode help",
      settingShowHelpForNudgeModes
    );
    UI::SetWindowSize(vec2(300, 500), UI::Cond::Appearing);

    UI::Markdown(nudgeModeHelpText);

    UI::End();
  }

  if (settingKeyInfoWaitingForKey !is null) {
    bool windowShown = true;
    vec2 size = vec2(250, 178);
    UI::PushStyleVar(UI::StyleVar::Alpha, 1.1);
    UI::Begin(
      "\\$f90" + Icons::Gavel + "\\$z Waiting for key...",
      windowShown,
      UI::WindowFlags::NoCollapse
      | UI::WindowFlags::NoResize
      | UI::WindowFlags::AlwaysAutoResize
    );
    UI::SetWindowSize(size);

    UI::TextWrapped(
      "Please press the key you want to assign to \\$f90"
      + settingKeyInfoWaitingForKey.displayName
    );
    string modifierKeys = virtualKeyToString(ModifierKeys::GetKeys(), true);
    modifierKeys = Regex::Replace(modifierKeys, " \\+", ",");
    UI::Text("Pressed modifier Keys: [ " + modifierKeys + " ]");

    UI::NewLine();
    if (UI::Button("Cancel")) {
      @settingKeyInfoWaitingForKey = null;
    }
    UI::SameLine();

    UI::End();
    UI::PopStyleVar();
    if (!windowShown || Time::get_Now() - lastSettingsRendered > 20) {
      @settingKeyInfoWaitingForKey = null;
    }
  }

  CGameCtnEditorFree@ editor = GetMapEditor();
  if (editor is null) return;

  if (settingShowInterface) {
    UI::Begin(
      "\\$f90" + Icons::Gavel + "\\$z Advanced Free Block Mode",
      settingShowInterface,
      UI::WindowFlags::NoResize
      | UI::WindowFlags::AlwaysAutoResize
      | UI::WindowFlags::NoDocking
    );
    CGameCursorBlock@ cursor = editor.Cursor;

    string modifierKeys = virtualKeyToString(ModifierKeys::GetKeys(), true);
    modifierKeys = Regex::Replace(modifierKeys, " \\+", ",");
    printUITextOnButtonBaseline("Pressed modifier Keys: [ " + modifierKeys + " ]");
    if (UI::Button("Reset")) {
      ModifierKeys::Reset();
    }

    if (UI::CollapsingHeader("Current position")) {
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
    }

    vec3[] nudgeDirs = {
      vec3(1, 0, 0),
      vec3(-1, 0, 0),
      vec3(0, 1, 0),
      vec3(0, -1, 0),
      vec3(0, 0, 1),
      vec3(0, 0, -1)
    };
    VirtualKey[][] keysForNudgeDirs(nudgeDirs.Length);
    for (uint i = 0; i < nudgeDirs.Length; i++) {
      if (nudgeMode == NudgeMode::Pivot || localCoords) {
        nudgeDirs[i] = rotateVec3(
          nudgeDirs[i],
          cursorYaw,
          cursorPitch,
          cursorRoll
        );
      }
      VectorToKeyFunc@ vectorToKey;
      SettingsNudgeMode var;
      string errorMessageThing = "";
      if (nudgeMode == NudgeMode::Rotation) {
        var = settingNudgeModeRotation;
        errorMessageThing = "rotating";
      } else {
        var = settingNudgeModeTranslation;
        errorMessageThing = "moving";
      }
      if (var == SettingsNudgeMode::Fixed) {
        @vectorToKey = NudgingFixedAxisPerKey::vectorToKey;
      } else if (var == SettingsNudgeMode::RelativeToCamera) {
        @vectorToKey = NudgingRelativeToCam::vectorToKey;
      } else if (var == SettingsNudgeMode::SelectedAxis) {
        @vectorToKey = NudgingSelectedAxis::vectorToKey;
      } else {
        @vectorToKey = function(vec3 vector) {
          return {};
        };
        print(
          "\\$f90Advanced Free Block Mode: \\$f00Unknown nudge mode for "
          + errorMessageThing
          + " the block: \\$z"
          + tostring(settingNudgeModeRotation)
        );
      }
      keysForNudgeDirs[i] = vectorToKey(nudgeDirs[i]);
    }

    if (!fixCursorPosition && nudgeMode == NudgeMode::Pivot) {
      nudgeMode = NudgeMode::Position;
    }

    string keysForHeaderBar = "";
    string empty = Icons::Kenney::ButtonEmpty;
    for (uint i = 0; i < keysForNudgeDirs.Length; i++) {
      VirtualKey[] k = keysForNudgeDirs[i];
      string s = k.Length == 0 ? "\\$f90" + empty + "\\$z" : virtualKeyToString(k, true);
      if (i > 0) {
        keysForHeaderBar += i % 2 == 0 ? " | " : " & ";
      }
      keysForHeaderBar += s;
    }

    bool isPosOrRotNudgeMode = nudgeMode == NudgeMode::Position || nudgeMode == NudgeMode::Rotation;
    bool isPivotNudgeMode = nudgeMode == NudgeMode::Pivot;
    string positionHeaderTitle = isPosOrRotNudgeMode ? "Fixed position" : "Pivot position";
    if (nudgeMode == NudgeMode::Position || nudgeMode == NudgeMode::Pivot) {
      positionHeaderTitle += " " + keysForHeaderBar;
    }
    if (UI::CollapsingHeader(positionHeaderTitle)) {
      if (isPosOrRotNudgeMode) {
        // ====================================== Fixed position
        UI::Columns(3, "2", false);

        UI::Text("X");
        if (fixCursorPosition) {
          UI::PushID("X");
          cursorPosition.x = UI::InputFloat("##Pos", cursorPosition.x, 0);
          UI::PopID();
        } else {
          UI::Text(Text::Format("%f", cursorPosition.x));
        }
        if (
          nudgeMode == NudgeMode::Position
          && keysForNudgeDirs[0].Length > 0
          && keysForNudgeDirs[1].Length > 0
        ) {
          UI::Text(
            "Nudge with\n"
            + virtualKeyToString(keysForNudgeDirs[0], true)
            + " & "
            + virtualKeyToString(keysForNudgeDirs[1], true)
          );
        }
        UI::NextColumn();

        UI::Text("Y");
        if (fixCursorPosition) {
          UI::PushID("Y");
          cursorPosition.y = UI::InputFloat("##Pos", cursorPosition.y, 0);
          UI::PopID();
        } else {
          UI::Text(Text::Format("%f", cursorPosition.y));
        }
        if (
          nudgeMode == NudgeMode::Position
          && keysForNudgeDirs[2].Length > 0
          && keysForNudgeDirs[3].Length > 0
        ) {
          UI::Text(
            "Nudge with\n"
            + virtualKeyToString(keysForNudgeDirs[2], true)
            + " & "
            + virtualKeyToString(keysForNudgeDirs[3], true)
          );
        }
        UI::NextColumn();

        UI::Text("Z");
        if (fixCursorPosition) {
          UI::PushID("Z");
          cursorPosition.z = UI::InputFloat("##Pos", cursorPosition.z, 0);
          UI::PopID();
        } else {
          UI::Text(Text::Format("%f", cursorPosition.z));
        }
        if (
          nudgeMode == NudgeMode::Position
          && keysForNudgeDirs[4].Length > 0
          && keysForNudgeDirs[5].Length > 0
        ) {
          UI::Text(
            "Nudge with\n"
            + virtualKeyToString(keysForNudgeDirs[4], true)
            + " & "
            + virtualKeyToString(keysForNudgeDirs[5], true)
          );
        }
        UI::Columns(1, "3", false);

        if (nudgeMode == NudgeMode::Position) {
          bool hasKey = false;
          for (uint i = 0; i < keysForNudgeDirs.Length; i++) {
            if (keysForNudgeDirs[i].Length > 0) {
              hasKey = true;
              break;
            }
          }
        }
      } else if (isPivotNudgeMode) {
        // ====================================== Pivot position
        UI::Columns(3, "2", false);

        UI::Text("X");
        UI::PushID("X");
        pivotPosition.x = UI::InputFloat("##Pivot", pivotPosition.x, 0);
        UI::PopID();
        if (keysForNudgeDirs[0].Length > 0 && keysForNudgeDirs[1].Length > 0) {
          UI::Text(
            "Nudge with\n"
            + virtualKeyToString(keysForNudgeDirs[0], true)
            + " & "
            + virtualKeyToString(keysForNudgeDirs[1], true)
          );
        }
        UI::NextColumn();

        UI::Text("Y");
        UI::PushID("Y");
        pivotPosition.y = UI::InputFloat("##Pivot", pivotPosition.y, 0);
        UI::PopID();
        if (keysForNudgeDirs[2].Length > 0 && keysForNudgeDirs[3].Length > 0) {
          UI::Text(
            "Nudge with\n"
            + virtualKeyToString(keysForNudgeDirs[2], true)
            + " & "
            + virtualKeyToString(keysForNudgeDirs[3], true)
          );
        }
        UI::NextColumn();

        UI::Text("Z");
        UI::PushID("Z");
        pivotPosition.z = UI::InputFloat("##Pivot", pivotPosition.z, 0);
        UI::PopID();
        if (keysForNudgeDirs[4].Length > 0 && keysForNudgeDirs[5].Length > 0) {
          UI::Text(
            "Nudge with\n"
            + virtualKeyToString(keysForNudgeDirs[4], true)
            + " & "
            + virtualKeyToString(keysForNudgeDirs[5], true)
          );
        }
        UI::Columns(1, "3", false);

        bool hasKey = false;
        for (uint i = 0; i < keysForNudgeDirs.Length; i++) {
          if (keysForNudgeDirs[i].Length > 0) {
            hasKey = true;
            break;
          }
        }
      }
    }


    if (
      UI::CollapsingHeader(
        "Fixed rotation"
        + (nudgeMode == NudgeMode::Rotation ? " " + keysForHeaderBar : "")
      )
    ) {
      if (settingRotationInDeg) {
        cursorYaw = Math::ToDeg(cursorYaw);
        cursorPitch = Math::ToDeg(cursorPitch);
        cursorRoll = Math::ToDeg(cursorRoll);
      }

      UI::Columns(3, "4", false);
        vec2 rotationSectionStartPos = UI::GetCursorPos();

      UI::Text("X (Roll)");
      if (fixCursorPosition) {
        UI::PushID("r");
        cursorRoll = UI::InputFloat("##Rotation", cursorRoll, 0);
        UI::PopID();
      } else {
        UI::Text(Text::Format("%f", cursorRoll));
      }
      if (
        nudgeMode == NudgeMode::Rotation
        && keysForNudgeDirs[0].Length > 0
        && keysForNudgeDirs[1].Length > 0
      ) {
        UI::Text(
          "Nudge with\n"
          + virtualKeyToString(keysForNudgeDirs[0], true)
          + " & "
          + virtualKeyToString(keysForNudgeDirs[1], true)
        );
      }
      UI::NextColumn();

      UI::Text("Y (Yaw)");
      if (fixCursorPosition) {
        UI::PushID("y");
        cursorYaw = UI::InputFloat("##Rotation", cursorYaw, 0);
        UI::PopID();
      } else {
        UI::Text(Text::Format("%f", cursorYaw));
      }
      if (
        nudgeMode == NudgeMode::Rotation
        && keysForNudgeDirs[2].Length > 0
        && keysForNudgeDirs[3].Length > 0
      ) {
        UI::Text(
          "Nudge with\n"
          + virtualKeyToString(keysForNudgeDirs[2], true)
          + " & "
          + virtualKeyToString(keysForNudgeDirs[3], true)
        );
      }
      UI::NextColumn();

      UI::Text("Z (Pitch)");
      if (fixCursorPosition) {
        UI::PushID("p");
        cursorPitch = UI::InputFloat("##Rotation", cursorPitch, 0);
        UI::PopID();
      } else {
        UI::Text(Text::Format("%f", cursorPitch));
      }
      if (
        nudgeMode == NudgeMode::Rotation
        && keysForNudgeDirs[4].Length > 0
        && keysForNudgeDirs[5].Length > 0
      ) {
        UI::Text(
          "Nudge with\n"
          + virtualKeyToString(keysForNudgeDirs[4], true)
          + " & "
          + virtualKeyToString(keysForNudgeDirs[5], true)
        );
      }
      UI::Columns(1, "5", false);

      if (nudgeMode == NudgeMode::Rotation) {
        bool hasKey = false;
        for (uint i = 0; i < keysForNudgeDirs.Length; i++) {
          if (keysForNudgeDirs[i].Length > 0) {
            hasKey = true;
            break;
          }
        }
      }

      if (settingRotationInDeg) {
        cursorYaw = Math::ToRad(cursorYaw);
        cursorPitch = Math::ToRad(cursorPitch);
        cursorRoll = Math::ToRad(cursorRoll);
      }

      vec2 rotationSectionEndPos = UI::GetCursorPos();
      float diff = Time::get_Now() - notifyNudgeKeyChange;
      if (diff < 2000) {
        if (settingShowTooltipOnNudgeModeNotify) {
          UI::BeginTooltip();
          UI::Text("The nudge direction of the last pressed key has changed!");
          UI::EndTooltip();
        }

        if (diff % 1000 < 500) {
          UI::DrawList@ drawList = UI::GetWindowDrawList();
          float width = UI::GetWindowSize().x;
          float height = rotationSectionEndPos.y - rotationSectionStartPos.y;
          vec2 winPos = UI::GetWindowPos()
            + rotationSectionStartPos
            - vec2(0, UI::GetScrollY())
            - vec2(8, 3);
          drawList.AddRectFilled(vec4(winPos.x, winPos.y, width, height), vec4(1, 0, 0, 0.1));
        }
      }
    }

    if (UI::CollapsingHeader("Toggles")) {
      bool oldFixCursorPos = fixCursorPosition;
      fixCursorPosition = UI::Checkbox("Fix cursor position", fixCursorPosition);
      if (oldFixCursorPos != fixCursorPosition && !fixCursorPosition) {
        cursor.UseSnappedLoc = false;
      }
      if (Keybindings::GetKey("ToggleFixedCursor").Length > 0) {
        UI::SameLine();
        UI::TextDisabled(
          "("
          + Keybindings::GetKeyString("ToggleFixedCursor", true)
          + ")"
        );
      }

      printUITextOnButtonBaseline("Nudge ");
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
      if (Keybindings::GetKey("ToggleNudgeMode").Length > 0) {
        UI::SameLine();
        UI::TextDisabled(
          "("
          + Keybindings::GetKeyString("ToggleNudgeMode", true)
          + ")"
        );
      }

      UI::BeginDisabled(!fixCursorPosition);
      if (UI::Checkbox("Nudge pivot point", nudgeMode == NudgeMode::Pivot)) {
        nudgeMode = NudgeMode::Pivot;
        localCoords = true;
      } else if (nudgeMode == NudgeMode::Pivot) {
        nudgeMode = NudgeMode::Rotation;
      }
      UI::EndDisabled();
      if (Keybindings::GetKey("ToggleNudgePivotPoint").Length > 0) {
        UI::SameLine();
        UI::TextDisabled(
          "("
          + Keybindings::GetKeyString("ToggleNudgePivotPoint", true)
          + ")"
        );
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
      if (Keybindings::GetKey("ToggleRelativeNudging").Length > 0) {
        UI::SameLine();
        UI::TextDisabled(
          "("
          + Keybindings::GetKeyString("ToggleRelativeNudging", true)
          + ")"
        );
      }

      if (fixCursorPosition) {
        refreshVariables = false;
      }
      refreshVariables = UI::Checkbox(
        "Refresh position & rotation variables",
        refreshVariables
      );
      if (Keybindings::GetKey("ToggleVariableUpdate").Length > 0) {
        UI::SameLine();
        UI::TextDisabled(
          "("
          + Keybindings::GetKeyString("ToggleVariableUpdate", true)
          + ")"
        );
      }

      if (!fixCursorPosition) {
        focusOnPivot = false;
      }
      focusOnPivot = UI::Checkbox("Focus camera on pivot", focusOnPivot);
      if (Keybindings::GetKey("ToggleFocusOnPivot").Length > 0) {
        UI::SameLine();
        UI::TextDisabled(
          "("
          + Keybindings::GetKeyString("ToggleFocusOnPivot", true)
          + ")"
        );
      }
      UI::SameLine();

      string focusOnceKeybinding = "";
      if (Keybindings::GetKey("FocusOnceOnPivot").Length > 0) {
        focusOnceKeybinding = " ("
          + Keybindings::GetKeyString("FocusOnceOnPivot", true)
          + ")";
      }
      if(UI::Button("Focus once" + focusOnceKeybinding)) {
        FocusCameraOnPivot();
      }

      editor.HideBlockHelpers = UI::Checkbox(
        "Hide block helpers",
        editor.HideBlockHelpers
      );
    }

    if (UI::CollapsingHeader("Step size")) {
      if (UI::BeginCombo(
        "##StepSize",
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
    }

    if (fixCursorPosition) {
      UI::NewLine();
      UI::TextWrapped(
        "Place the block by clicking anywhere.\n"
        + "If it flickers, move your mouse or wait a few seconds.\n"
        + "This is because the game thinks the block should be beneath your mouse pointer."
      );
    }
    UI::End();
  }
}

bool OnKeyPress(bool down, VirtualKey key) {
  if (settingKeyInfoWaitingForKey !is null) {
    if (!ModifierKeys::Handle(down, key)) {
      auto keys = ModifierKeys::GetKeys(key);
      Keybindings::SetKey(settingKeyInfoWaitingForKey.name, keys);
      @settingKeyInfoWaitingForKey = null;
      return true;
    }
  }
  
  if (!settingShowInterface)
    return false;
  CGameCtnEditorFree@ editor = GetMapEditor();
  if (editor is null)
    return false;

  // maybe handles it twice, but that is no problem
  ModifierKeys::Handle(down, key);

  if (!down) return false;

  bool handled = false;
  vec3 move = vec3();
  float stepSizeRad = Math::ToRad(settingStepSizeRotation);
  float rotationDelta = 0;

  KeyToVectorFunc@ keyToVector;
  SettingsNudgeMode var;
  string errorMessageThing = "";
  if (nudgeMode == NudgeMode::Rotation) {
    var = settingNudgeModeRotation;
    errorMessageThing = "rotating";
  } else {
    var = settingNudgeModeTranslation;
    errorMessageThing = "moving";
  }
  if (var == SettingsNudgeMode::Fixed) {
    @keyToVector = NudgingFixedAxisPerKey::keyToVector;
  } else if (var == SettingsNudgeMode::RelativeToCamera) {
    @keyToVector = NudgingRelativeToCam::keyToVector;
  } else if (var == SettingsNudgeMode::SelectedAxis) {
    @keyToVector = NudgingSelectedAxis::keyToVector;
  } else {
    print(
      "\\$f90Advanced Free Block Mode: \\$f00Unknown nudge mode for "
      + errorMessageThing
      + " the block: \\$z"
      + tostring(settingNudgeModeRotation)
    );
    return false;
  }

  VirtualKey[] keyCombination = ModifierKeys::GetKeys(key);

  vec3 nudgeDir = keyToVector(keyCombination);
  vec3 axis = nudgeDir;
  if (!VectorsEqual(nudgeDir, vec3())) {
    if (nudgeMode == NudgeMode::Position || nudgeMode == NudgeMode::Pivot) {
      move += nudgeDir * settingStepSizePosition;
    } else {
      rotationDelta = stepSizeRad;
    }
  } else if (Keybindings::Matches("ToggleNudgeMode", keyCombination)) {
    nudgeMode = 
      nudgeMode == NudgeMode::Position
      || nudgeMode == NudgeMode::Pivot
        ? NudgeMode::Rotation
        : NudgeMode::Position;
    handled = true;
  } else if (Keybindings::Matches("ToggleNudgePivotPoint", keyCombination)) {
    nudgeMode = 
      nudgeMode == NudgeMode::Pivot
        ? NudgeMode::Rotation
        : NudgeMode::Pivot;
    handled = true;
  } else if (Keybindings::Matches("ToggleVariableUpdate", keyCombination)) {
    refreshVariables = !refreshVariables;
    handled = true;
  } else if (Keybindings::Matches("ToggleRelativeNudging", keyCombination)) {
    localCoords = !localCoords;
    handled = true;
  } else if (Keybindings::Matches("ToggleFixedCursor", keyCombination)) {
    fixCursorPosition = !fixCursorPosition;
    handled = true;
  } else if (Keybindings::Matches("ToggleFocusOnPivot", keyCombination)) {
    focusOnPivot = !focusOnPivot;
    handled = true;
  } else if (Keybindings::Matches("FocusOnceOnPivot", keyCombination)) {
    FocusCameraOnPivot();
    handled = true;
  } else if (
    Keybindings::Matches("CycleAxis", keyCombination)
    && (
      (
        nudgeMode == NudgeMode::Rotation
        ? settingNudgeModeRotation
        : settingNudgeModeTranslation
      ) == SettingsNudgeMode::SelectedAxis
    )
  ) {
    NudgingSelectedAxis::nudgeAxisIndex =
      (NudgingSelectedAxis::nudgeAxisIndex + 1)
      % NudgingSelectedAxis::nudgeAxes.Length;
    handled = true;
  }

  if (fixCursorPosition) {
    // undo movement of page up & down keys
    // if (key == VirtualKey::Prior) {
    //   editor.OrbitalCameraControl.m_TargetedPosition.y -= 1;
    //   editor.OrbitalCameraControl.Pos.y -= 1;
    // } else if (key == VirtualKey::Next) {
    //   editor.OrbitalCameraControl.m_TargetedPosition.y += 1;
    //   editor.OrbitalCameraControl.Pos.y += 1;
    // }

    if (move.Length() > 0) {
      if (nudgeMode == NudgeMode::Pivot) {
        pivotPosition += move;
      } else {
        cursorPosition += move;
      }
      handled = true;
    } else if (rotationDelta > 0) {
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
      // check if key has changed
      // FIXME: they sometimes are not equal even though the direction hasn't changed
      vec3 newNudgeDir = keyToVector(keyCombination);
      if (!VectorsEqual(nudgeDir, newNudgeDir)) {
        notifyNudgeKeyChange = Time::get_Now();
      }
      
      handled = true;
    }
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
