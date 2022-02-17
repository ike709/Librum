import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import librum.extensions.sidebar
import "../components/sidebar"


Page
{
    id: root
    
    MSidebar
    {
        anchors.left: parent.left
        focus: true
        selectedTab: SidebarState.Settings
    }
    
    Label
    {
        anchors.centerIn: parent
        text: "Settings"
        font.pointSize: 22
        font.bold: true
    }
}