class NudgingFixedAxisPerKey {
  vec3 keyToVector(VirtualKey key) {
    vec3 move = vec3(0, 0, 0);
    vec3 axis = vec3(0, 0, 0);
    if (key == settingKeyLeft) {
      if (nudgeMode == NudgeMode::Position || nudgeMode == NudgeMode::Pivot) {
        move.x -= settingStepSizePosition 
          * (positionNudgeMode == PositionNudgeMode::GridSizeMultiple ? 32 : 1);
      } else {
        axis.x -= 1;
      }
    } else if (key == settingKeyRight) {
      if (nudgeMode == NudgeMode::Position || nudgeMode == NudgeMode::Pivot) {
        move.x += settingStepSizePosition 
          * (positionNudgeMode == PositionNudgeMode::GridSizeMultiple ? 32 : 1);
      } else {
        axis.x += 1;
      }
    } else if (key == settingKeyForward) {
      if (nudgeMode == NudgeMode::Position || nudgeMode == NudgeMode::Pivot) {
        move.z += settingStepSizePosition 
          * (positionNudgeMode == PositionNudgeMode::GridSizeMultiple ? 32 : 1);
      } else {
        axis.z += 1;
      }
    } else if (key == settingKeyBackward) {
      if (nudgeMode == NudgeMode::Position || nudgeMode == NudgeMode::Pivot) {
        move.z -= settingStepSizePosition 
          * (positionNudgeMode == PositionNudgeMode::GridSizeMultiple ? 32 : 1);
      } else {
        axis.z -= 1;
      }
    } else if (key == settingKeyDown) {
      if (nudgeMode == NudgeMode::Position || nudgeMode == NudgeMode::Pivot) {
        move.y -= settingStepSizePosition 
          * (positionNudgeMode == PositionNudgeMode::GridSizeMultiple ? 8 : 1);
      } else {
        axis.y -= 1;
      }
    } else if (key == settingKeyUp) {
      if (nudgeMode == NudgeMode::Position || nudgeMode == NudgeMode::Pivot) {
        move.y += settingStepSizePosition 
          * (positionNudgeMode == PositionNudgeMode::GridSizeMultiple ? 8 : 1);
      } else {
        axis.y += 1;
      }
    }

    if (move.LengthSquared() > 0) {
      if (localCoords) {
        move = rotateVec3(move, cursorYaw, cursorPitch, cursorRoll);
      }
      return move;
    } else {
      return axis;
    }
  }

  VirtualKey vectorToKey(vec3 vector) {
    if (localCoords || nudgeMode == NudgeMode::Pivot) {
      // rotate vector back
      mat4 Ry = mat4::Rotate(-cursorYaw, vec3(0, 1, 0));
      mat4 Rz = mat4::Rotate(-cursorPitch, vec3(0, 0, 1));
      mat4 Rx = mat4::Rotate(-cursorRoll, vec3(1, 0, 0));

      mat4 R = Rx * Rz * Ry;
      vector = vecRemoveLastD(R * vector);
    }
    VirtualKey[] keys = {
      settingKeyLeft,
      settingKeyRight,
      settingKeyUp,
      settingKeyDown,
      settingKeyForward,
      settingKeyBackward
    };
    vec3[] dirs = {
      vec3(-1, 0, 0),
      vec3(1, 0, 0),
      vec3(0, 1, 0),
      vec3(0, -1, 0),
      vec3(0, 0, 1),
      vec3(0, 0, -1)
    };
    for (uint i = 0; i < dirs.Length; i++) {
      if (VectorsEqual(vector, dirs[i])) {
        return keys[i];
      }
    }
    return nullKey;
  }
}
