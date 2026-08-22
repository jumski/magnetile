#!/bin/sh

set -eu

SCRIPT_NAME="magnetile-jumski"

usage() {
    cat <<EOF
Usage: $(basename "$0") [--normal]

Build, install, enable, and safely reload Magnetile in a KDE Wayland session.

Options:
  --normal    Disable/unload, package/install, then reload KWin scripting.
  -h, --help  Show this help.
EOF
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --normal)
            ;;
        --restart|--full|--kwin-restart)
            echo "$(basename "$0"): Refusing an in-session KWin replacement on Wayland; save work and log out/in instead." >&2
            exit 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "$(basename "$0"): Unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
    shift
done

if [ "${XDG_SESSION_TYPE:-}" != "wayland" ]; then
    echo "$(basename "$0"): Magnetile supports Wayland sessions only." >&2
    exit 1
fi

for command in make kwriteconfig6 qdbus6; do
    if ! command -v "${command}" >/dev/null 2>&1; then
        echo "$(basename "$0"): Missing required command: ${command}" >&2
        exit 1
    fi
done

REPO_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "${REPO_DIR}"

echo "Magnetile safe reload"
echo "Repository: ${REPO_DIR}"
echo
echo "1. Disabling and unloading ${SCRIPT_NAME}..."
kwriteconfig6 --file kwinrc --group Plugins --key "${SCRIPT_NAME}Enabled" false
qdbus6 org.kde.KWin /Scripting org.kde.kwin.Scripting.unloadScript "${SCRIPT_NAME}" >/dev/null 2>&1 || true
qdbus6 org.kde.KWin /KWin reconfigure

echo
echo "2. Packaging and installing with make..."
make

echo
echo "3. Enabling ${SCRIPT_NAME} in kwinrc..."
kwriteconfig6 --file kwinrc --group Plugins --key "${SCRIPT_NAME}Enabled" true

echo
echo "4. Reconfiguring KWin and starting scripting..."
qdbus6 org.kde.KWin /KWin reconfigure
qdbus6 org.kde.KWin /Scripting org.kde.kwin.Scripting.start

echo
echo "Safe reload requested."
echo
echo "Next steps:"
echo "  - Watch recent logs:"
echo "      journalctl --user -u plasma-kwin_wayland --since \"1 minute ago\""
echo "  - Confirm shortcut actions:"
echo "      qdbus6 org.kde.kglobalaccel /component/kwin org.kde.kglobalaccel.Component.shortcutNames | rg \"Magnetile jumski\""
echo "  - If KWin process state must be cleared, save work and log out/in."
