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

        // Fix viewport scaling for OAuth pages that lack <meta name="viewport">.
        //
        // Problem: on Android WebView (unlike QtWebEngine on desktop), injecting a
        // viewport meta tag via JavaScript after page load does NOT trigger a viewport
        // recalculation — the layout viewport is fixed at parse time (~980 px for pages
        // without a viewport tag).  We therefore also apply a CSS zoom so the already-
        // rendered content is scaled to fit the device width.  The zoom factor is
        // computed as  screen.width / document.documentElement.scrollWidth  so that
        // pages that already fit the screen (e.g. Zewo, which ships its own viewport
        // tag) are left untouched (zoom ≈ 1).
        //
        // Injecting the meta tag is kept because it benefits desktop WebEngine builds
        // and future Android WebView versions that may support dynamic viewport updates.
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
                    "  if (!document.getElementById('__qt_vp_style')) {" +
                    "    var s = document.createElement('style');" +
                    "    s.id = '__qt_vp_style';" +
                    "    s.textContent = 'html{-webkit-text-size-adjust:100%!important;text-size-adjust:100%!important}';" +
                    "    document.head.appendChild(s);" +
                    "  }" +
                    "  var scrollW = document.documentElement.scrollWidth;" +
                    "  var screenW = window.screen.width;" +
                    "  var zoom = 1;" +
                    "  if (scrollW > screenW * 1.1) {" +
                    "    zoom = screenW / scrollW;" +
                    "    document.body.style.zoom = zoom;" +
                    "  }" +
                    "  return JSON.stringify({url: location.href, viewportBefore: before," +
                    "    screenWidth: screenW, innerWidth: window.innerWidth," +
                    "    scrollWidth: scrollW, devicePixelRatio: window.devicePixelRatio," +
                    "    zoomApplied: zoom});" +
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
