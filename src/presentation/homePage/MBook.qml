import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Librum.style
import Librum.icons
import CustomComponents
import Librum.fonts
import Librum.globals

Item {
    id: root
    property bool downloading: false
    signal leftButtonClicked(int index)
    signal rightButtonClicked(int index, var mouse)
    signal moreOptionClicked(int index, var point)

    implicitWidth: 190
    implicitHeight: 322

    Connections {
        target: model

        function onDownloadedChanged() {
            if (model.downloaded)
                root.downloading = false
        }
    }

    ColumnLayout {
        id: layout
        anchors.fill: parent
        spacing: 0


        /**
          A Item with rounded corners which is overlapping with the top half of
          the book to create a rounded top, while the rest of the book is rectangluar
          */
        Item {
            id: upperBookRounding
            Layout.preferredHeight: 10
            Layout.fillWidth: true
            clip: true

            Rectangle {
                id: upperRoundingFiller
                height: parent.height + 4
                width: parent.width
                radius: 4
                color: Style.colorBookImageBackground
            }
        }


        /**
          An overlay over the upper-book-rounding to get it to be transparent and modal,
          when the book is not currently downloaded. It leads to visual bugs to apply
          the properties directly to the upper-book-rounding item. Moving a separate object
          over it is working fine without any visual bugs
          */
        Item {
            id: upperBookRoundingDimmer
            Layout.topMargin: -upperBookRounding.height
            Layout.preferredHeight: 10
            Layout.fillWidth: true
            visible: !model.downloaded
            clip: true
            z: 2

            Rectangle {
                id: dimmerRect
                height: upperRoundingFiller.height
                width: upperRoundingFiller.width
                color: Style.colorBookCoverDim
                opacity: 0.5
                radius: 4
            }
        }

        Rectangle {
            id: upperBookPart
            Layout.fillWidth: true
            Layout.preferredHeight: 230
            color: Style.colorBookImageBackground

            Rectangle {
                id: bookCoverDimmer
                anchors.fill: parent
                visible: !model.downloaded
                color: Style.colorBookCoverDim
                opacity: 0.5
                z: 2
            }

            Image {
                id: downloadBookIcon
                anchors.centerIn: bookCoverDimmer
                visible: !model.downloaded && !downloadProgressBar.visible
                sourceSize.width: 52
                fillMode: Image.PreserveAspectFit
                source: Icons.downloadSelected
                opacity: 1
                z: 3
            }

            ColumnLayout {
                id: upperPartLayout
                anchors.centerIn: parent
                spacing: 0

                Image {
                    id: bookCover
                    visible: source != ""
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: -10
                    source: cover
                    cache: false
                }


                /*
                  The item displaying when no book cover exists (usually a ".format" label)
                 */
                Label {
                    id: noImageLabel
                    Layout.alignment: Qt.AlignCenter
                    visible: bookCover.source == ""
                    text: "." + model.format
                    color: Style.colorNoImageLabel
                    font.pointSize: Fonts.size20
                    font.bold: true
                }
            }

            MProgressBar {
                id: downloadProgressBar
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottomMargin: 1
                anchors.leftMargin: 1
                anchors.rightMargin: 1
                visible: false
                z: 3
                progress: model.mediaDownloadProgress
                onProgressChanged: {
                    if (progress === 1)
                        visible = false
                    else
                        visible = true
                }
            }
        }

        Rectangle {
            id: lowerBookPart
            Layout.fillWidth: true
            Layout.preferredHeight: 90
            color: Style.colorBookBackground
            border.width: 1
            border.color: Style.colorBookBorder

            ColumnLayout {
                id: bottomPartLayout
                width: parent.width - internal.lowerBookPartPadding * 2
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 0

                Label {
                    id: title
                    Layout.fillWidth: true
                    Layout.preferredHeight: 34
                    Layout.topMargin: 5
                    clip: true
                    text: model.title === "" ? qsTr("Unknown") : model.title
                    font.weight: Font.Medium
                    verticalAlignment: Text.AlignVCenter
                    color: Style.colorTitle
                    font.pointSize: Fonts.size11
                    lineHeight: 0.8
                    wrapMode: TextInput.WrapAtWordBoundaryOrAnywhere
                    elide: Text.ElideRight
                }

                Label {
                    id: authors
                    Layout.fillWidth: true
                    Layout.topMargin: 4
                    clip: true
                    text: model.authors === "" ? qsTr("Unknown") : model.authors
                    color: Style.colorLightText
                    font.pointSize: Fonts.size10
                    elide: Text.ElideRight
                }

                RowLayout {
                    id: statusRow
                    Layout.fillWidth: true
                    spacing: 0

                    Rectangle {
                        id: readingProgressBox
                        Layout.preferredWidth: 46
                        Layout.preferredHeight: 18
                        Layout.topMargin: 4
                        color: Style.colorHighlight
                        radius: 2

                        Label {
                            id: readingProgressLabel
                            anchors.centerIn: parent
                            horizontalAlignment: Text.AlignBottom
                            text: model.bookReadingProgress + "%"
                            font.weight: Font.DemiBold
                            color: Style.colorTitle
                            font.pointSize: Fonts.size10
                        }
                    }
                }
            }
        }
    }

    MouseArea {
        id: bookArea
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        cursorShape: Qt.PointingHandCursor

        // Delegate mouse clicks events to parent
        onClicked: mouse => {
                       if (mouse.button === Qt.LeftButton) {
                           root.leftButtonClicked(root.index)
                       } else if (mouse.button === Qt.RightButton) {
                           root.rightButtonClicked(root.index, mouse)
                       }
                   }
    }

    RowLayout {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: title.width
        spacing: 0

        Image {
            id: existsOnlyOnClientIndicator
            Layout.leftMargin: readingProgressBox.width - 5
            Layout.topMargin: 4
            Layout.bottomMargin: 2
            Layout.alignment: Qt.AlignVCenter
            visible: model.existsOnlyOnClient
            sourceSize.width: 18
            fillMode: Image.PreserveAspectFit
            source: Icons.cloudOff

            MouseArea {
                id: existsOnlyOnClientIndicatorArea
                anchors.fill: parent
                hoverEnabled: true
                onContainsMouseChanged: containsMouse ? toolTip.open(
                                                            ) : toolTip.close()
            }
        }

        Item {
            Layout.fillWidth: true
        }

        Image {
            id: moreOptionsIcon
            Layout.preferredHeight: 20
            Layout.rightMargin: 12
            source: Icons.dots
            fillMode: Image.PreserveAspectFit
            antialiasing: false

            MouseArea {
                id: moreOptionsArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: mouse => {
                               if (mouse.button === Qt.LeftButton) {
                                   let point = mapToItem(bookArea,
                                                         Qt.point(mouse.x,
                                                                  mouse.y))
                                   root.moreOptionClicked(root.index, point)
                               }
                           }
            }
        }
    }

    MCheckBox {
        id: checkBox
        anchors.top: root.top
        anchors.left: root.left
        anchors.topMargin: 10
        anchors.leftMargin: 10
        visible: Globals.bookSelectionModeEnabled
        uncheckedBackgroundColor: Style.colorControlBackground
    }

    QtObject {
        id: internal
        property int lowerBookPartPadding: 14
        property var bookSelectionModeEnabled: Globals.bookSelectionModeEnabled

        onBookSelectionModeEnabledChanged: {
            if (bookSelectionModeEnabled === false) {
                checkBox.checked = false
            }
        }
    }

    MToolTip {
        id: toolTip
        focusedItem: existsOnlyOnClientIndicator
        content: qsTr("Your book has not been uploaded to the cloud.\nEither you are offline, or your storage is full.")
    }

    function select() {
        checkBox.checked = true
    }

    function deselect() {
        checkBox.checked = false
    }

    function giveFocus() {
        root.forceActiveFocus()
    }
}
