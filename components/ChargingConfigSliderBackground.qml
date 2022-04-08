import QtQuick 2.0
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3






    RowLayout{
        id: chargingConfigSlider
        Layout.fillWidth: true
        spacing: 0

        property real infeasibleSectionWidth
        property real feasibleSectionWidth
        property real maybeFeasibleSectionWidth



        Rectangle{
            id: infeasibleSection
            x: chargingConfigSlider.parent.leftPadding
            y: chargingConfigSlider.parent.topPadding + chargingConfigSlider.parent.Height / 2 - height / 2

            implicitWidth: parent.infeasibleSectionWidth ? parent.infeasibleSectionWidth : 0
            implicitHeight: 4
            color: "red"

            Rectangle{
            id: leftborder
            width: 5
            height: 10

            color: "white"
            }



        }

        Rectangle{
            id: maybeFeasibleSection
            x: chargingConfigSlider.parent.leftPadding
            y: chargingConfigSlider.parent.topPadding + chargingConfigSlider.parent.availableHeight / 2 - height / 2
            implicitWidth: parent.maybeFeasibleSectionWidth ? parent.maybeFeasibleSectionWidth : 0
            implicitHeight: 4
            color: "yellow"



        }

        Rectangle{
            id: feasibleSection
            x: chargingConfigSlider.parent.leftPadding
            y: chargingConfigSlider.parent.topPadding + chargingConfigSlider.parent.availableHeight / 2 - height / 2
            implicitWidth: parent.feasibleSectionWidth ? parent.feasibleSectionWidth : 0
            implicitHeight: 4
            color: "green"

            Rectangle{
            id: rightborder
            anchors.right: parent.right
            width: 6
            height: 10

            color: "white"
            }



        }





    }


