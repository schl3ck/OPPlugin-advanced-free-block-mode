namespace Keybindings {
  class KeyInfo {
    string name;
    VirtualKey[] defaultKey;
    VirtualKey[] key;
    string description;
    VirtualKey[] oldKey;

    KeyInfo(const KeyInfo &in other) {
      this.name = other.name;
      this.defaultKey = copyKeys(other.defaultKey);
      this.key = copyKeys(other.key);
      this.description = other.description;
      this.oldKey = copyKeys(other.oldKey);
    }
    KeyInfo(const const string &in name, const VirtualKey[] &in key, const const string &in description, const VirtualKey[] &in oldKey) {
      this.name = name;
      this.defaultKey = key;
      this.key = key;
      this.description = description;
      this.oldKey = oldKey;
    }

    string opImplConv() const {
      string s = "";
      for (uint i = 0; i < this.key.Length; i++) {
        if (i > 0) {
          s += ", ";
        }
        s += tostring(this.key[i]);
      }
      return this.name + ": { " + s + " }";
    }
  };


  KeyInfo@[] keys = {
    KeyInfo("Forward", { VirtualKey::Up }, "Moves the block in the horizontal plane", { VirtualKey::I }),
    KeyInfo("Backward", { VirtualKey::Down }, "Moves the block in the horizontal plane", { VirtualKey::K }),
    KeyInfo("Left", { VirtualKey::Left }, "Moves the block in the horizontal plane", { VirtualKey::J }),
    KeyInfo("Right", { VirtualKey::Right }, "Moves the block in the horizontal plane", { VirtualKey::L }),
    KeyInfo("Up", { VirtualKey::Prior }, "Moves the block on the vertical axis", { VirtualKey::N }),
    KeyInfo("Down", { VirtualKey::Next }, "Moves the block on the vertical axis", { VirtualKey::B }),
    KeyInfo("CycleAxis", { VirtualKey::B }, "Only used in Nudge Mode 'SelectedAxis'", {}),
    KeyInfo("ToggleFixedCursor", { VirtualKey::N }, "", {}),
    KeyInfo("ToggleNudgeMode", { VirtualKey::L }, "", { VirtualKey::G }),
    KeyInfo("ToggleNudgePivotPoint", {}, "", {}),
    KeyInfo("ToggleRelativeNudging", { VirtualKey::J }, "", { VirtualKey::O }),
    KeyInfo("ToggleVariableUpdate", { VirtualKey::T }, "", { VirtualKey::T }),
    KeyInfo("ToggleFocusOnPivot", {}, "Focus the camera continuously on the pivot point", {}),
    KeyInfo("FocusOnceOnPivot", {}, "Focus the camera once on the pivot point", {})
  };

  KeyInfo@ Find(const string &in name) {
    for (uint i = 0; i < keys.Length; i++) {
      if (keys[i].name == name)
        return keys[i];
    }
    return null;
  }

  void SetKey(const string &in name, const VirtualKey[] &in key) {
    KeyInfo@ k = Find(name);
    if (k !is null) {
      k.key = key;
    }
  }

  VirtualKey[] GetKey(const string &in name) {
    KeyInfo@ k = Find(name);
    if (k !is null) {
      return k.key;
    }
    return {};
  }
  bool Equals(const VirtualKey[] &in a, const VirtualKey[] &in b) {
    if (a.Length != b.Length) {
      return false;
    }
    for (uint i = 0; i < a.Length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }
  bool Matches(const string &in name, const VirtualKey[] &in keys) {
    VirtualKey[] forName = GetKey(name);
    return Equals(keys, forName);
  }
  string GetKeyString(const string &in name, bool colorize = false) {
    KeyInfo@ k = Find(name);
    if (k !is null) {
      return virtualKeyToString(k.key, colorize);
    }
    return "";
  }
  string GetKeyDescription(const string &in name) {
    KeyInfo@ k = Find(name);
    if (k !is null) {
      return k.description;
    }
    return "";
  }

  VirtualKey[] GetDefaultKey(const string &in name) {
    KeyInfo@ k = Find(name);
    if (k !is null) {
      return k.defaultKey;
    }
    return {};
  }

  void ResetKey(const string &in name) {
    KeyInfo@ k = Find(name);
    if (k !is null) {
      k.key = copyKeys(k.defaultKey);
    }
  }

  void ResetAllKeys() {
    for (uint i = 0; i < keys.Length; i++) {
      KeyInfo@ k = keys[i];
      k.key = copyKeys(k.defaultKey);
    }
  }

  void SetKeysToOldMapping() {
    for (uint i = 0; i < keys.Length; i++) {
      KeyInfo@ k = keys[i];
      k.key = copyKeys(k.oldKey);
    }
  }

  string Serialize() {
    Json::Value json = Json::Object();

    for (uint i = 0; i < keys.Length; i++) {
      KeyInfo@ k = keys[i];
      auto arr = Json::Array();
      for (uint i2 = 0; i2 < k.key.Length; i2++) {
        arr.Add(int(k.key[i2]));
      }
      json[k.name] = arr;
    }

    return Json::Write(json);
  }

  void Deserialize(const string &in text) {
    Json::Value json = Json::Parse(text);
    if (json.GetType() != Json::Type::Object) return;
    string[]@ names = json.GetKeys();
    for (uint i = 0; i < names.Length; i++) {
      Json::Value value = json[names[i]];
      Json::Type type = value.GetType();
      if (type == Json::Type::Number) {
        int key = value;
        SetKey(names[i], { VirtualKey(key) });
      } else if (type == Json::Type::Array) {
        VirtualKey[] keys(value.Length, VirtualKey(0));
        for (uint i2 = 0; i2 < value.Length; i2++) {
          keys[i2] = VirtualKey(int(value[i2]));
        }
        SetKey(names[i], keys);
      }
    }
  }

  VirtualKey[] copyKeys(VirtualKey[] arr) {
    // let AngelScript do the work
    return arr;
  }
}
