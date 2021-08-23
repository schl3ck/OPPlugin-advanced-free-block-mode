
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

float ArrayMax(float[]& ar) {
  if (ar is null) return 0;
  if (ar.Length == 0) return 0;
  float max = 0x8000f;
  for (uint i = 1; i < ar.Length; i++) {
    max = Math::Max(max, ar[i]);
  }
  return max;
}

string ArrayToString(float[]& ar) {
  int maxLen = 80;
  string[] strs;
  // "{ " + " }" = length of 4
  int len = 4;
  for (uint i = 0; i < ar.Length; i++) {
    strs.InsertLast(tostring(ar[i]));
    len += strs[i].Length;
  }
  bool linebreaks = len > maxLen;
  string s = "{";
  for (uint i = 0; i < strs.Length; i++) {
    s += (i > 0 ? "," : "") + (linebreaks ? "\n  " : " ") + strs[i];
  }
  return s + (linebreaks ? "\n" : " ") + "}";
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
