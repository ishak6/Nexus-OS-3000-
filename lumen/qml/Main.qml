import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root
    width: 1280
    height: 800
    minimumWidth: 900
    minimumHeight: 600
    visible: true
    title: "Nexus LUMEN"
    color: darkMode ? "#10131b" : "#f2f4f8"

    property bool darkMode: true
    property string activePage: "Overview"
    property color surface: darkMode ? "#191f2b" : "#ffffff"
    property color foreground: darkMode ? "#edf2ff" : "#172033"
    property color muted: darkMode ? "#9ba8bd" : "#68758a"
    property color accent: "#8b9cff"

    function navigate(page) { activePage = page }

    component NavButton: Button {
        required property string label
        required property string glyph
        property bool selected: false
        Layout.fillWidth: true
        implicitHeight: 48
        flat: true
        highlighted: selected
        contentItem: RowLayout {
            spacing: 14
            Label { text: glyph; color: selected ? root.accent : root.muted; font.pixelSize: 18 }
            Label { text: label; color: root.foreground; font.pixelSize: 14; Layout.fillWidth: true }
        }
        background: Rectangle {
            radius: 12
            color: selected ? (root.darkMode ? "#29334b" : "#e8edff") : "transparent"
        }
    }

    component InfoCard: Rectangle {
        required property string heading
        required property string value
        required property string detail
        Layout.fillWidth: true
        Layout.preferredHeight: 142
        radius: 18
        color: root.surface
        border.color: root.darkMode ? "#2a3445" : "#e1e6ef"
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 9
            Label { text: heading; color: root.muted; font.pixelSize: 13 }
            Label { text: value; color: root.foreground; font.pixelSize: 27; font.weight: Font.DemiBold }
            Label { text: detail; color: root.muted; font.pixelSize: 12; wrapMode: Text.Wrap }
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.preferredWidth: 244
            Layout.fillHeight: true
            color: root.darkMode ? "#151a24" : "#e9edf5"
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 18
                RowLayout {
                    Layout.fillWidth: true
                    Rectangle { width: 38; height: 38; radius: 12; color: "#7187ff"
                        Label { anchors.centerIn: parent; text: "N"; color: "white"; font.bold: true; font.pixelSize: 20 }
                    }
                    ColumnLayout { spacing: 1
                        Label { text: "NEXUS"; color: root.foreground; font.bold: true; font.pixelSize: 16 }
                        Label { text: "LUMEN  ·  PREVIEW"; color: root.muted; font.pixelSize: 9; letterSpacing: 1.2 }
                    }
                }
                Label { text: "WORKSPACE"; color: root.muted; font.pixelSize: 10; font.bold: true; Layout.topMargin: 16 }
                NavButton { label: "Overview"; glyph: "◈"; selected: root.activePage === label; onClicked: root.navigate(label) }
                NavButton { label: "Living Space"; glyph: "▦"; selected: root.activePage === label; onClicked: root.navigate(label) }
                NavButton { label: "Orbit"; glyph: "◎"; selected: root.activePage === label; onClicked: root.navigate(label) }
                Label { text: "SYSTEM"; color: root.muted; font.pixelSize: 10; font.bold: true; Layout.topMargin: 18 }
                NavButton { label: "Pulse"; glyph: "⌁"; selected: root.activePage === label; onClicked: root.navigate(label) }
                NavButton { label: "Security"; glyph: "⬡"; selected: root.activePage === label; onClicked: root.navigate(label) }
                NavButton { label: "Privacy"; glyph: "◇"; selected: root.activePage === label; onClicked: root.navigate(label) }
                Item { Layout.fillHeight: true }
                NavButton { label: "Settings"; glyph: "⚙"; selected: root.activePage === label; onClicked: root.navigate(label) }
                Label { text: "Experimental build · Not production"; color: root.muted; font.pixelSize: 10; wrapMode: Text.Wrap; Layout.fillWidth: true }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 28
            spacing: 22
            RowLayout {
                Layout.fillWidth: true
                ColumnLayout { spacing: 3
                    Label { text: "NEXUS OS 3000"; color: root.muted; font.pixelSize: 11; letterSpacing: 1.4 }
                    Label { text: root.activePage; color: root.foreground; font.pixelSize: 28; font.bold: true }
                }
                Item { Layout.fillWidth: true }
                Button { text: root.darkMode ? "Light mode" : "Dark mode"; onClicked: root.darkMode = !root.darkMode }
                Rectangle { width: 38; height: 38; radius: 19; color: root.surface
                    Label { anchors.centerIn: parent; text: "I"; color: root.foreground; font.bold: true }
                }
            }

            Flickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentWidth: width
                contentHeight: contentColumn.implicitHeight
                clip: true
                ColumnLayout {
                    id: contentColumn
                    width: parent.width
                    spacing: 18
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 174
                        radius: 22
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: root.darkMode ? "#28375d" : "#dce4ff" }
                            GradientStop { position: 1.0; color: root.darkMode ? "#25263e" : "#eee7ff" }
                        }
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 24
                            spacing: 8
                            Label { text: root.activePage === "Overview" ? "A calmer space for focused work." : root.activePage; color: root.foreground; font.pixelSize: 23; font.bold: true }
                            Label { text: root.activePage === "Overview" ? "Your workspace, system controls and privacy tools in one place." : "LUMEN preview surface. System integration is not connected yet."; color: root.muted; font.pixelSize: 13; wrapMode: Text.Wrap }
                            Item { Layout.fillHeight: true }
                            Label { text: "NEXUS LUMEN  /  EARLY PREVIEW"; color: root.accent; font.pixelSize: 10; font.bold: true; letterSpacing: 1.2 }
                        }
                    }
                    GridLayout {
                        Layout.fillWidth: true
                        columns: width > 1050 ? 3 : 2
                        columnSpacing: 14
                        rowSpacing: 14
                        InfoCard { heading: "CPU LOAD"; value: "—"; detail: "Telemetry service not connected" }
                        InfoCard { heading: "MEMORY"; value: "—"; detail: "Telemetry service not connected" }
                        InfoCard { heading: "NETWORK"; value: "—"; detail: "Network monitor not connected" }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 112
                        radius: 18
                        color: root.surface
                        border.color: root.darkMode ? "#2a3445" : "#e1e6ef"
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 14
                            Label { text: "ⓘ"; color: root.accent; font.pixelSize: 22 }
                            ColumnLayout { Layout.fillWidth: true; spacing: 4
                                Label { text: "Preview, not yet the active system shell"; color: root.foreground; font.bold: true; font.pixelSize: 14 }
                                Label { text: "This prototype does not replace XFCE, manage windows, or enforce security policies. Those integrations require separate implementation and VM testing."; color: root.muted; font.pixelSize: 12; wrapMode: Text.Wrap; Layout.fillWidth: true }
                            }
                        }
                    }
                }
            }
        }
    }
}
