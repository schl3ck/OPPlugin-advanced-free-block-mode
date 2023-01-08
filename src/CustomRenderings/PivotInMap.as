class PivotInMap {

  void RenderInterface() {}

  void Render(vec3 pivotPosition) {
    if (!Camera::IsBehind(pivotPosition)) {
      vec2 point = Camera::ToScreenSpace(pivotPosition);

      nvg::BeginPath();
      nvg::FillColor(vec4(0, 0, 0, 1));
      nvg::Circle(point, 10);
      nvg::ClosePath();
      nvg::Fill();

      nvg::BeginPath();
      nvg::FillColor(vec4(1, 0, 0, 1));
      nvg::Circle(point, 6);
      nvg::ClosePath();
      nvg::Fill();
    }
  }
}
