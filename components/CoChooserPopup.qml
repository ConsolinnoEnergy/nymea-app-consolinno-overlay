// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQuick.Layouts
import Nymea

// Generic searchable single-selection chooser overlay: a search field
// followed by a filtered list of items. Filtering itself is left to the
// caller - either bind filterText to a model's own filter property (e.g.
// ThingClassesProxy.filterString) or re-filter a plain array externally
// and reassign it to `model`.
//
// The supplied `delegate` is responsible for setting `selection` and
// calling `accept()` when an item is picked, e.g.:
//
//     CoChooserPopup {
//         id: chooserPopup
//         title: qsTr("Choose a model")
//         model: someFilterableModel
//         delegate: CoCard {
//             text: model.displayName
//             onClicked: {
//                 chooserPopup.selection = model.id
//                 chooserPopup.accept()
//             }
//         }
//         onAccepted: console.log("Chosen:", chooserPopup.selection)
//     }
CoOverlay {
    id: root

    hasAcceptButton: false

    property alias model: listView.model
    property alias delegate: listView.delegate
    property var selection: undefined

    property alias searchLabelText: filterInput.labelText
    property alias listHeaderText: selectionGroup.headerText
    property alias filterText: filterInput.textField.displayText

    searchLabelText: qsTr("Search")

    onAboutToShow: {
        filterInput.textField.clear();
        filterInput.textField.forceActiveFocus();
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing: 0

        CoInputField {
            id: filterInput
            Layout.fillWidth: true
        }

        CoFrostyCard {
            id: selectionGroup
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: Style.margins
            contentTopMargin: 8

            ListView {
                id: listView
                anchors.right: parent.right
                anchors.left: parent.left
                implicitHeight: selectionGroup.height - 50
                clip: true
            }
        }
    }
}
