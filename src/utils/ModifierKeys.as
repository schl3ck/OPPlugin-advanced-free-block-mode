namespace ModifierKeys {
  bool LControl = false;
  bool RControl = false;
  bool LMenu = false;
  bool RMenu = false;
  bool LShift = false;
  bool RShift = false;
  bool LWin = false;
  bool RWin = false;

  bool Control {
    get {
      return LControl || RControl;
    }
  }
  bool Menu {
    get {
      return LMenu || RMenu;
    }
  }
  bool Shift {
    get {
      return LShift || RShift;
    }
  }
  bool Win {
    get {
      return LWin || RWin;
    }
  }

  VirtualKey[] GetKeys() {
    VirtualKey[] keys(b2i(Control) + b2i(Menu) + b2i(Shift) + b2i(Win), VirtualKey(0));
    uint i = 0;
    if (Control) {
      keys[i] = VirtualKey::Control;
      i++;
    }
    if (Win) {
      keys[i] = VirtualKey::Lwin;
      i++;
    }
    if (Menu) {
      keys[i] = VirtualKey::Menu;
      i++;
    }
    if (Shift) {
      keys[i] = VirtualKey::Shift;
      i++;
    }
    return keys;
  }
  VirtualKey[] GetKeys(VirtualKey additionalKey) {
    VirtualKey[] keys(b2i(Control) + b2i(Menu) + b2i(Shift) + b2i(Win) + 1, VirtualKey(0));
    uint i = 0;
    if (Control) {
      keys[i] = VirtualKey::Control;
      i++;
    }
    if (Win) {
      keys[i] = VirtualKey::Lwin;
      i++;
    }
    if (Menu) {
      keys[i] = VirtualKey::Menu;
      i++;
    }
    if (Shift) {
      keys[i] = VirtualKey::Shift;
      i++;
    }
    keys[i] = additionalKey;
    return keys;
  }

  bool Handle(bool down, VirtualKey key) {
    // print("ModifierKeys::handle, down=" + tostring(down) + ", key=" + tostring(key));
    switch (key) {
      case VirtualKey::Control: LControl = down; break;
      case VirtualKey::LControl: LControl = down; break;
      case VirtualKey::RControl: RControl = down; break;
      case VirtualKey::Menu: LMenu = down; break;
      case VirtualKey::LMenu: LMenu = down; break;
      case VirtualKey::RMenu: RMenu = down; break;
      case VirtualKey::Shift: LShift = down; break;
      case VirtualKey::LShift: LShift = down; break;
      case VirtualKey::RShift: RShift = down; break;
      case VirtualKey::Lwin: LWin = down; break;
      case VirtualKey::Rwin: RWin = down; break;
      default: return false;
    }
    return true;
  }

  void Reset() {
    LControl = false;
    RControl = false;
    LMenu = false;
    RMenu = false;
    LShift = false;
    RShift = false;
    LWin = false;
    RWin = false;
  }
}
