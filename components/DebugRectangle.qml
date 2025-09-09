import QtQuick 2.0

Rectangle {
  property var toFill: parent          // instantiation site "can" (optionally) override
  property color customColor: 'red' // instantiation site "can" (optionally) override
  property int customThickness: 1      // instantiation site "can" (optionally) override

  anchors.fill: toFill
  z: 200
  color: 'transparent'
  border.color: customColor
  border.width: customThickness
}
