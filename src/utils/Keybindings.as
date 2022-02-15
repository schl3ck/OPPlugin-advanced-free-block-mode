namespace Keybindings {
  class KeyInfo {
    string name;
    VirtualKey defaultKey;
    VirtualKey key;
    string description;
    VirtualKey oldKey;

    KeyInfo(const KeyInfo &in other) {
      this.name = other.name;
      this.defaultKey = other.defaultKey;
      this.key = other.key;
      this.description = other.description;
      this.oldKey = other.oldKey;
    }
    KeyInfo(string name, VirtualKey key, string description, VirtualKey oldKey) {
      this.name = name;
      this.defaultKey = key;
      this.key = key;
      this.description = description;
      this.oldKey = oldKey;
    }
  };


  KeyInfo@[] keys = {
    KeyInfo("Forward", VirtualKey::Up, "Moves the block in the horizontal plane", VirtualKey::I),
    KeyInfo("Backward", VirtualKey::Down, "Moves the block in the horizontal plane", VirtualKey::K),
    KeyInfo("Left", VirtualKey::Left, "Moves the block in the horizontal plane", VirtualKey::J),
    KeyInfo("Right", VirtualKey::Right, "Moves the block in the horizontal plane", VirtualKey::L),
    KeyInfo("Up", VirtualKey::Prior, "Moves the block on the vertical axis", VirtualKey::N),
    KeyInfo("Down", VirtualKey::Next, "Moves the block on the vertical axis", VirtualKey::B),
    KeyInfo("ToggleFixedCursor", VirtualKey::N, "", VirtualKey(0)),
    KeyInfo("ToggleNudgeMode", VirtualKey::L, "", VirtualKey::G),
    KeyInfo("ToggleRelativeNudging", VirtualKey::J, "", VirtualKey::O),
    KeyInfo("ToggleVariableUpdate", VirtualKey::T, "", VirtualKey::T),
    KeyInfo("CycleAxis", VirtualKey::B, "Only used in Nudge Mode 'SelectedAxis'", VirtualKey(0)),
  };

  KeyInfo@ Find(string name) {
    for (uint i = 0; i < keys.Length; i++) {
      if (keys[i].name == name)
        return keys[i];
    }
    return null;
  }

  void SetKey(string name, VirtualKey key) {
    KeyInfo@ k = Find(name);
    if (k !is null) {
      k.key = key;
    }
  }

  VirtualKey GetKey(string name) {
    KeyInfo@ k = Find(name);
    if (k !is null) {
      return k.key;
    }
    return VirtualKey(0);
  }
  string GetKeyString(string name) {
    KeyInfo@ k = Find(name);
    if (k !is null) {
      return virtualKeyToString(k.key);
    }
    return "";
  }
  string GetKeyDescription(string name) {
    KeyInfo@ k = Find(name);
    if (k !is null) {
      return k.description;
    }
    return "";
  }

  VirtualKey GetDefaultKey(string name) {
    KeyInfo@ k = Find(name);
    if (k !is null) {
      return k.defaultKey;
    }
    return VirtualKey(0);
  }

  void ResetKey(string name) {
    KeyInfo@ k = Find(name);
    if (k !is null) {
      k.key = k.defaultKey;
    }
  }

  void ResetAllKeys() {
    for (uint i = 0; i < keys.Length; i++) {
      KeyInfo@ k = keys[i];
      k.key = k.defaultKey;
    }
  }

  void SetKeysToOldMapping() {
    for (uint i = 0; i < keys.Length; i++) {
      KeyInfo@ k = keys[i];
      k.key = k.oldKey;
    }
  }

  string Serialize() {
    Json::Value json = Json::Object();

    for (uint i = 0; i < keys.Length; i++) {
      KeyInfo@ k = keys[i];
      json[k.name] = Json::Value(int(k.key));
    }

    return Json::Write(json);
  }

  void Deserialize(string text) {
    Json::Value json = Json::Parse(text);
    if (json.GetType() != Json::Type::Object) return;
    string[]@ names = json.GetKeys();
    for (uint i = 0; i < names.Length; i++) {
      int key = json[names[i]];
      SetKey(names[i], VirtualKey(key));
    }
  }
}
