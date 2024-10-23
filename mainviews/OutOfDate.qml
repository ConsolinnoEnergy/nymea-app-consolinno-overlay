
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import QtCharts 2.3
import Nymea 1.0
import Qt.labs.settings 1.1
import QtGraphicalEffects 1.15

import "../components"
import "../delegates"

MainViewBase {
    id: root

            Label {
           verticalAlignment: Text.AlignVCenter
           anchors.centerIn: parent
           width: parent.width *0.8
           wrapMode: "WordWrap"
           text: qsTr("This version of the App (%3) is not compatibile with the software running on your %4 system (%2) .\nPlease upgrade your %4 system software to at least version %1.\n\nPlease refer to our service if you have any questions: %5").arg(Configuration.minSysVersion).arg(engine.jsonRpcClient.experiences.Hems).arg(appVersion).arg(Configuration.appName).arg(Configuration.serviceEmail)
           font.pixelSize: 18
            }

    }

