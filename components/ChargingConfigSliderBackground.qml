import QtQuick 2.0
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3






    RowLayout{
        id: chargingConfigSlider
        Layout.fillWidth:true
        spacing: 0

        property real infeasibleSectionWidth
        property real feasibleSectionWidth




        Rectangle{
            id: infeasibleSection
            x: chargingConfigSlider.parent.leftPadding
            y: chargingConfigSlider.parent.topPadding + chargingConfigSlider.parent.Height / 2 - height / 2
            Layout.leftMargin: 0
            Layout.minimumWidth: infeasibleSectionWidth

            implicitHeight: 4
            color: "red"




        }

        Rectangle{
            id: feasibleSection
            x: chargingConfigSlider.parent.leftPadding
            y: chargingConfigSlider.parent.topPadding + chargingConfigSlider.parent.availableHeight / 2 - height / 2

            Layout.leftMargin: 0
            Layout.minimumWidth: feasibleSectionWidth
            implicitHeight: 4
            color: "green"





        }





    }


