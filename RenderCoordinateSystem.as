class CoordinateSystem {

  vec2 size = vec2(160, 160);
  CGameControlCameraEditorOrbital@ Camera { 
    get const {
      auto editor = cast<CGameCtnEditorFree>(GetApp().Editor);
      if (editor is null) return null;
      return editor.OrbitalCameraControl;
    }
  }

  void RenderInterface() {
    if (!settingMoveCoordinateSystem) return;

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
    UI::SetWindowSize(size, UI::Cond::Always);
    settingCoordinateSystemPosition = UI::GetWindowPos();

    // UI::Text("V " + Camera.m_CurrentVAngle); // pitch
    // UI::Text("H " + Camera.m_CurrentHAngle); // yaw

    UI::End();
  }

  void Render(bool local, float yaw, float pitch, float roll) {
    vec2 curPos = vec2(settingCoordinateSystemPosition);
    float scale = 50;
    float textMargin = 10;

    nvg::FontFace(font);

    nvg::BeginPath();
    nvg::FillColor(vec4(1, 1, 1, 0.2));
    nvg::RoundedRect(curPos.x, curPos.y, size.x, size.y, 10);
    nvg::Fill();
    nvg::StrokeWidth(3);
    nvg::StrokeColor(vec4(1, 1, 1, 1));
    nvg::Stroke();

    nvg::FontSize(18);
    nvg::FillColor(vec4(0, 0, 0, 1));
    nvg::TextAlign(nvg::Align::Right | nvg::Align::Bottom);
    nvg::Text(
      curPos.x + size.x - 7,
      curPos.y + size.y - 5,
      local ? "Local" : "Global"
    );

    curPos += size / 2;
    vec2 startPos = vec2(curPos);
    nvg::StrokeWidth(2);
    nvg::TextAlign(nvg::Align::Center | nvg::Align::Middle);
    nvg::FontSize(18);
    dictionary[] dirWithColor = {
      {{"dir", vec3(-1, 0, 0)}, {"color", vec4(1, 0, 0, 1)}, {"label", "X"}},
      {{"dir", vec3(0, 1, 0)}, {"color", vec4(0, 0, 1, 1)}, {"label", "Y"}},
      {{"dir", vec3(0, 0, 1)}, {"color", vec4(0, 1, 0, 1)}, {"label", "Z"}}
    };
    for (uint i = 0; i < dirWithColor.Length; i++) {
      vec3 v = vec3(dirWithColor[i]["dir"]);
      if (local) {
        v = rotateVec3(v, -yaw, -pitch, roll);
      }
      dirWithColor[i]["dir"] = projectVectorToViewingPlane(v) * scale;
    }
    dirWithColor.Sort(function(a, b) {
      return vec3(a["dir"]).z > vec3(b["dir"]).z;
    });
    for (uint i = 0; i < dirWithColor.Length; i++) {
      dictionary dict = dirWithColor[i];
      nvg::StrokeColor(vec4(dict["color"]));
      nvg::FillColor(vec4(dict["color"]));
      nvg::BeginPath();
      nvg::MoveTo(startPos);
      vec3 dir3 = vec3(dict["dir"]);
      vec2 dir2 = vec2(dir3.x, dir3.y);
      curPos = startPos + dir2;
      nvg::LineTo(curPos);
      nvg::ClosePath();
      nvg::Stroke();

      curPos += dir2 / dir2.Length() * textMargin;
      nvg::Text(curPos.x, curPos.y, string(dict["label"]));
    }

  }

  vec3 projectVectorToViewingPlane(vec3 dir) {
    float yaw = Camera.m_CurrentHAngle;
    float pitch = Camera.m_CurrentVAngle;
    vec3 x = vec3(1, 0, 0);
    vec3 y = vec3(0, 1, 0);
    vec3 z = vec3(0, 0, 1);

    mat4 mYaw = mat4::Rotate(-yaw, y);
    // mat3 m3Yaw = mat3::Rotate(yaw);
    mat4 mPitch = mat4::Rotate(pitch, x);
    vec3 planeNormal = vec4To3(mYaw * mPitch * z);
    // up in screen coords is negative => * -1
    vec3 planeVertical = vec4To3(mYaw * mPitch * y) * -1;
    vec3 planeHorizontal = Math::Cross(planeNormal, planeVertical);

    // project dir into viewing plane
    vec3 projected = dir - (planeNormal * Math::Dot(dir, planeNormal));

    // get coordinates in viewing plane
    vec3 dir2D = vec3(
      Math::Dot(projected, planeHorizontal),
      Math::Dot(projected, planeVertical),
      // set depth information
      Math::Dot(dir, planeNormal)
    );

    return dir2D;
  }
}
