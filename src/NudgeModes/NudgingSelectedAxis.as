namespace NudgingSelectedAxis {
  vec3[]@ nudgeAxes = {
    vec3(1, 0, 0),
    vec3(0, 1, 0),
    vec3(0, 0, 1)
  };
  uint nudgeAxisIndex = 0;

  vec3 keyToVector(const VirtualKey[] &in keys) {
    vec3 axis = vec3(0, 0, 0);
    vec3 gridSizeMultiple = vec3(32, 8, 32);
    vec3 step = vec3(0, 0, 0);
    if (
      Keybindings::Matches("Left", keys)
      || Keybindings::Matches("Backward", keys)
    ) {
      if (nudgeMode == NudgeMode::Position || nudgeMode == NudgeMode::Pivot) {
        step -= (
            positionNudgeMode == PositionNudgeMode::GridSizeMultiple
            ? gridSizeMultiple
            : vec3(1, 1, 1)
          );
      } else {
        step -= vec3(1, 1, 1);
      }
    } else if (
      Keybindings::Matches("Right", keys)
      || Keybindings::Matches("Forward", keys)
    ) {
      if (nudgeMode == NudgeMode::Position || nudgeMode == NudgeMode::Pivot) {
        step += (
            positionNudgeMode == PositionNudgeMode::GridSizeMultiple
            ? gridSizeMultiple
            : vec3(1, 1, 1)
          );
      } else {
        step += vec3(1, 1, 1);
      }
    }

    axis += nudgeAxes[nudgeAxisIndex] * step;
    if (settingNudgeRelativeToBlockOrientation) {
      axis = rotateVec3(axis, cursorYaw, cursorPitch, cursorRoll);
    }
    return axis;
  }

  VirtualKey[] vectorToKey(vec3 vector) {
    if (settingNudgeRelativeToBlockOrientation || nudgeMode == NudgeMode::Pivot) {
      // rotate vector back
      mat4 Ry = mat4::Rotate(-cursorYaw, vec3(0, 1, 0));
      mat4 Rz = mat4::Rotate(-cursorPitch, vec3(0, 0, 1));
      mat4 Rx = mat4::Rotate(-cursorRoll, vec3(1, 0, 0));

      mat4 R = Rx * Rz * Ry;
      vector = vecRemoveLastD(R * vector);
    }
    if (VectorsEqual(vector, nudgeAxes[nudgeAxisIndex])) {
      return Keybindings::GetKey("Right");
    } else if (VectorsEqual(vector, nudgeAxes[nudgeAxisIndex] * -1)) {
      return Keybindings::GetKey("Left");
    }
    return {};
  }
}
