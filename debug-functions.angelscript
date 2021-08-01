
bool OnMouseButton(bool down, int button, int x, int y) {
  if (!settingShowInterface || !down)
    return false;
  CGameCtnEditorFree@ editor = GetMapEditor();
  if (editor is null)
    return false;

  if (fixCursorPosition && button == 0) {
    fixCursorPosition = false;
  }
  return false;
}

string[] floatArrToStrArr(float[] arr) {
  string[] res;
  for (uint i = 0; i < arr.Length; i++) {
    res.InsertLast("" + arr[i]); // Text::Format("%f", arr[i])
  }
  return res;
}

void printMatrix(mat3 m, string text = "") {
  float[] items = {m.xx, m.xy, m.xz, m.yx, m.yy, m.yz, m.zx, m.zy, m.zz};
  string str = text + " [\n";
  string[] ar;
  for (uint i = 0; i < items.Length; i++) {
    if (i % 3 == 0) ar.RemoveRange(0, ar.Length);
    ar.InsertLast(Text::Format("%f", items[i]));
    if (i % 3 == 2)
      str += "  [" + string::Join(ar, ", ") + "]\n";
  }
  print(str + "]");
}
void printMatrix(mat4 m, string text = "") {
  float[] items = {
    m.xx, m.xy, m.xz, m.xw,
    m.yx, m.yy, m.yz, m.yw,
    m.zx, m.zy, m.zz, m.zw,
    m.tx, m.ty, m.tz, m.tw
  };
  string str = text + " [\n";
  string[] ar;
  for (uint i = 0; i < items.Length; i++) {
    if (i % 4 == 0) ar.RemoveRange(0, ar.Length);
    ar.InsertLast(Text::Format("%f", items[i]));
    if (i % 4 == 3)
      str += "  [" + string::Join(ar, ", ") + "]\n";
  }
  print(str + "]");
}
