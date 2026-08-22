import QtQuick
import org.kde.kwin

Item {
    readonly property var shiftedNumberKeys: ["!", "@", "#", "$", "%", "^", "&", "*", "("]

    signal cycleLayouts()
    signal cycleLayoutsReversed()
    signal moveActiveWindowToNextZone()
    signal moveActiveWindowToPreviousZone()
    signal toggleZoneOverlay()
    signal switchToNextWindowInCurrentZone()
    signal switchToPreviousWindowInCurrentZone()
    signal moveActiveWindowToZone(int zone)
    signal activateLayout(int layout)
    signal moveActiveWindowUp()
    signal moveActiveWindowDown()
    signal moveActiveWindowLeft()
    signal moveActiveWindowRight()
    signal snapActiveWindow()
    signal snapAllWindows()
    signal freeActiveWindow()
    signal resetCurrentLayout()

    ShortcutHandler {
        name: "Magnetile jumski: Cycle layouts"
        text: "Magnetile jumski: Cycle layouts"
        sequence: "Ctrl+Alt+D"
        onActivated: {
            cycleLayouts();
        }
    }

    ShortcutHandler {
        name: "Magnetile jumski: Cycle layouts (reversed)"
        text: "Magnetile jumski: Cycle layouts (reversed)"
        sequence: "Ctrl+Alt+Shift+D"
        onActivated: {
            cycleLayoutsReversed();
        }
    }

    ShortcutHandler {
        name: "Magnetile jumski: Move active window to next zone"
        text: "Magnetile jumski: Move active window to next zone"
        sequence: "Ctrl+Alt+Right"
        onActivated: {
            moveActiveWindowToNextZone();
        }
    }

    ShortcutHandler {
        name: "Magnetile jumski: Move active window to previous zone"
        text: "Magnetile jumski: Move active window to previous zone"
        sequence: "Ctrl+Alt+Left"
        onActivated: {
            moveActiveWindowToPreviousZone();
        }
    }

    ShortcutHandler {
        name: "Magnetile jumski: Toggle zone overlay"
        text: "Magnetile jumski: Toggle zone overlay"
        sequence: "Ctrl+Alt+C"
        onActivated: {
            toggleZoneOverlay();
        }
    }

    ShortcutHandler {
        name: "Magnetile jumski: Switch to next window in current zone"
        text: "Magnetile jumski: Switch to next window in current zone"
        sequence: "Ctrl+Alt+Up"
        onActivated: {
            switchToNextWindowInCurrentZone();
        }
    }

    ShortcutHandler {
        name: "Magnetile jumski: Switch to previous window in current zone"
        text: "Magnetile jumski: Switch to previous window in current zone"
        sequence: "Ctrl+Alt+Down"
        onActivated: {
            switchToPreviousWindowInCurrentZone();
        }
    }

    Repeater {
        model: [1, 2, 3, 4, 5, 6, 7, 8, 9]

        delegate: Item {
            ShortcutHandler {
                name: "Magnetile jumski: Move active window to zone " + modelData
                text: "Magnetile jumski: Move active window to zone " + modelData
                sequence: "Ctrl+Alt+" + modelData
                onActivated: {
                    moveActiveWindowToZone(modelData - 1);
                }
            }

        }

    }

    Repeater {
        model: [1, 2, 3, 4, 5, 6, 7, 8, 9]

        delegate: Item {
            ShortcutHandler {
                name: "Magnetile jumski: Activate layout " + modelData
                text: "Magnetile jumski: Activate layout " + modelData
                sequence: "Ctrl+Alt+Shift+" + modelData
                onActivated: {
                    activateLayout(modelData - 1);
                }
            }

            ShortcutHandler {
                name: "Magnetile jumski: Activate layout " + modelData + " (shifted key)"
                text: "Magnetile jumski: Activate layout " + modelData + " (shifted key)"
                sequence: "Ctrl+Alt+" + shiftedNumberKeys[modelData - 1]
                onActivated: {
                    activateLayout(modelData - 1);
                }
            }

        }

    }

    ShortcutHandler {
        name: "Magnetile jumski: Move active window up"
        text: "Magnetile jumski: Move active window up"
        sequence: "Meta+Up"
        onActivated: {
            moveActiveWindowUp();
        }
    }

    ShortcutHandler {
        name: "Magnetile jumski: Move active window down"
        text: "Magnetile jumski: Move active window down"
        sequence: "Meta+Down"
        onActivated: {
            moveActiveWindowDown();
        }
    }

    ShortcutHandler {
        name: "Magnetile jumski: Move active window left"
        text: "Magnetile jumski: Move active window left"
        sequence: "Meta+Left"
        onActivated: {
            moveActiveWindowLeft();
        }
    }

    ShortcutHandler {
        name: "Magnetile jumski: Move active window right"
        text: "Magnetile jumski: Move active window right"
        sequence: "Meta+Right"
        onActivated: {
            moveActiveWindowRight();
        }
    }

    ShortcutHandler {
        name: "Magnetile jumski: Snap active window"
        text: "Magnetile jumski: Snap active window"
        sequence: "Meta+Shift+Space"
        onActivated: {
            snapActiveWindow();
        }
    }

    ShortcutHandler {
        name: "Magnetile jumski: Snap all windows"
        text: "Magnetile jumski: Snap all windows"
        sequence: "Meta+Space"
        onActivated: {
            snapAllWindows();
        }
    }

    ShortcutHandler {
        name: "Magnetile jumski: Free active window"
        text: "Magnetile jumski: Free active window"
        sequence: "Ctrl+Alt+F"
        onActivated: {
            freeActiveWindow();
        }
    }

    ShortcutHandler {
        name: "Magnetile jumski: Reset current layout"
        text: "Magnetile jumski: Reset current layout"
        sequence: "Ctrl+Alt+R"
        onActivated: {
            resetCurrentLayout();
        }
    }

}
