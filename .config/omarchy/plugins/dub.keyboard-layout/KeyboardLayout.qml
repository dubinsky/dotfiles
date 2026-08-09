import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.Ui
import qs.Commons

BarWidget {
  id: root
  moduleName: "dub.keyboard-layout"

  property string layoutLabel: ""
  property string layoutFull: ""
  property string keyboardName: ""
  property bool refreshPending: false

  function isVirtual(name) {
    return String(name).startsWith("hl-virtual-keyboard")
  }

  function isAux(name) {
    const n = String(name)
    return n.endsWith("-consumer-control")
      || n.endsWith("-system-control")
      || n.startsWith("power-button")
      || n === "sleep-button"
      || n === "video-bus"
      || n.startsWith("yubico-")
  }

  function isTrackable(name) {
    return name && !isVirtual(name) && !isAux(name)
  }

  function labelFromKeymap(keymap) {
    return String(keymap).split(/\s+/)[0].substring(0, 3).toUpperCase()
  }

  function applyLayout(device, keymap) {
    if (!keymap) return
    if (device && isTrackable(device))
      root.keyboardName = String(device)
    root.layoutFull = String(keymap)
    root.layoutLabel = labelFromKeymap(keymap)
  }

  function refresh() {
    if (queryProc.running) {
      root.refreshPending = true
      return
    }
    queryProc.running = true
  }

  // Prefer a real keyboard. When devices disagree (Alt+Alt only flips the
  // keyboard that generated the key event), prefer the one that is not on
  // layout index 0 if any, then *-keyboard, then last tracked name.
  function selectKeyboard(keyboards) {
    const typed = keyboards.filter(k => isTrackable(k.name))
    if (typed.length === 0) return null

    const nonDefault = typed.filter(k => Number(k.active_layout_index || 0) !== 0)
    return nonDefault.find(k => k.name === root.keyboardName)
      ?? nonDefault.find(k => String(k.name).endsWith("-keyboard"))
      ?? nonDefault[0]
      ?? typed.find(k => k.name === root.keyboardName)
      ?? typed.find(k => String(k.name).endsWith("-keyboard"))
      ?? typed.find(k => k.main)
      ?? typed[0]
  }

  // Hyprland 0.56+ Lua eval broke `hyprctl dispatch switchxkblayout …`.
  // The dedicated top-level command still works; `all` keeps devices in sync.
  function cycleLayout() {
    Quickshell.execDetached(["hyprctl", "switchxkblayout", "all", "next"])
    refreshSoon.restart()
  }

  Component.onCompleted: refresh()

  Connections {
    target: Hyprland
    function onRawEvent(event) {
      if (!event || !event.name) return
      const ename = String(event.name || "")
      if (ename.indexOf("activelayout") === -1) return

      // Prefer parse(2): [device, layout name] (layout may contain commas).
      let device = ""
      let keymap = ""
      try {
        const parts = event.parse(2)
        device = String(parts[0] || "")
        keymap = String(parts[1] || "")
      } catch (e) {
        const data = String(event.data || "")
        const comma = data.indexOf(",")
        if (comma >= 0) {
          device = data.substring(0, comma)
          keymap = data.substring(comma + 1)
        }
      }

      if (device && keymap && isTrackable(device))
        root.applyLayout(device, keymap)

      // Always re-query soon: covers bulk `all` switches and any device we skipped.
      refreshSoon.restart()
    }
  }

  Process {
    id: queryProc
    command: ["hyprctl", "-j", "devices"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        let kb
        try {
          kb = root.selectKeyboard(JSON.parse(text || "{}").keyboards ?? [])
        } catch (e) {
          return
        }
        if (!kb) return
        root.applyLayout(kb.name, kb.active_keymap)
      }
    }
    onExited: function() {
      if (root.refreshPending) {
        root.refreshPending = false
        root.refresh()
      }
    }
  }

  Timer {
    id: refreshSoon
    interval: 120
    onTriggered: root.refresh()
  }

  // Backup if socket events are missed (bar widgets sometimes lag on activelayout).
  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: root.refresh()
  }

  visible: layoutLabel !== ""
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.layoutLabel
    fontSize: Style.font.caption
    horizontalMargin: 6
    tooltipText: root.layoutFull
    onPressed: function() { root.cycleLayout() }
  }
}
