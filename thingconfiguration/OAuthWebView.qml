// SPDX-License-Identifier: GPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of nymea-app.
*
* nymea-app is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* nymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with nymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

// This file exists as a standalone QML file so that "import QtWebView" is
// visible to the QML import scanner used by androiddeployqt and
// linuxdeploy-plugin-qt. When this import is embedded in a Qt.createQmlObject
// string it is invisible to the scanner and the WebView plugin is not packaged.

import QtQuick
import QtQuick.Controls
import QtWebView

Item {
    anchors.fill: parent

    property string oAuthUrl
    signal pairingFinished(string redirectUrl)

    BusyIndicator {
        anchors.centerIn: parent
        running: oAuthWebView.loading
    }

    WebView {
        id: oAuthWebView
        anchors.fill: parent
        url: parent.oAuthUrl

        // Inject a responsive viewport meta tag once the page has loaded.
        // OAuth pages that lack <meta name="viewport"> render at desktop scale
        // on Android — this ensures they fit the screen width.
        // We always overwrite the content, even if a viewport tag exists,
        // because some pages set a fixed desktop width (e.g. width=1200).
        onLoadingChanged: function(loadRequest) {
            if (loadRequest.status === WebView.LoadSucceededStatus) {
                runJavaScript(
                    "(function() {" +
                    "  var m = document.querySelector('meta[name=viewport]');" +
                    "  var before = m ? m.content : '(none)';" +
                    "  if (!m) {" +
                    "    m = document.createElement('meta');" +
                    "    m.name = 'viewport';" +
                    "    document.head.appendChild(m);" +
                    "  }" +
                    "  m.content = 'width=device-width, initial-scale=1';" +
                    "  return JSON.stringify({url: location.href, viewportBefore: before, viewportAfter: m.content});" +
                    "})();",
                    function(result) { console.warn('OAuthWebView viewport fix:', result); }
                )
            }
        }

        onUrlChanged: {
            var urlStr = url.toString()
            if (urlStr.indexOf("https://127.0.0.1") === 0 || urlStr.indexOf("device-complete") >= 0) {
                oAuthWebView.visible = false
                pairingFinished(url)
            }
        }
    }
}
