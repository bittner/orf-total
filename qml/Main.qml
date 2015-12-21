import QtQuick 2.2
import Ubuntu.Web 0.2
import Ubuntu.Components 1.1
import com.canonical.Oxide 1.0 as Oxide
import "UCSComponents"
import Ubuntu.Content 1.1
import QtMultimedia 5.0
import QtFeedback 5.0
import "."
import "../config.js" as Conf

MainView {
    objectName: "mainView"

    applicationName: "orf-total.peter-bittner"

    useDeprecatedToolbar: false
    anchorToKeyboard: true
    automaticOrientation: true

    property string myUrl: Conf.webappUrl
    property string myPattern: Conf.webappUrlPattern

    property string myUA: Conf.webappUA ? Conf.webappUA : "Mozilla/5.0 (Linux; Android 5.0; Nexus 5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.102 Mobile Safari/537.36"

    Page {
        id: page
        anchors {
            fill: parent
            bottom: parent.bottom
        }
        width: parent.width
        height: parent.height

        HapticsEffect {
            id: vibration
            attackIntensity: 0.0
            attackTime: 50
            intensity: 1.0
            duration: 10
            fadeTime: 50
            fadeIntensity: 0.0
        }

        SoundEffect {
            id: clicksound
            source: "../sounds/Click.wav"
        }

        WebContext {
            id: webcontext
            userAgent: myUA
        }
        WebView {
            id: webview
            anchors {
                fill: parent
                bottom: parent.bottom
            }
            width: parent.width
            height: parent.height

            context: webcontext
            url: myUrl
            preferences.localStorageEnabled: true
            preferences.allowFileAccessFromFileUrls: true
            preferences.allowUniversalAccessFromFileUrls: true
            preferences.appCacheEnabled: true
            preferences.javascriptCanAccessClipboard: true
            filePicker: filePickerLoader.item

            function navigationRequestedDelegate(request) {
                var url = request.url.toString();
                var pattern = myPattern.split(',');
                var isvalid = false;

                if (Conf.hapticLinks) {
                    vibration.start()
                }

                if (Conf.audibleLinks) {
                    clicksound.play()
                }

                for (var i=0; i<pattern.length; i++) {
                    var tmpsearch = pattern[i].replace(/\*/g,'(.*)')
                    var search = tmpsearch.replace(/^https\?:\/\//g, '(http|https):\/\/');
                    if (url.match(search)) {
                       isvalid = true;
                       break
                    }
                }
                if(isvalid == false) {
                    console.warn("Opening remote: " + url);
                    Qt.openUrlExternally(url)
                    request.action = Oxide.NavigationRequest.ActionReject
                }
            }
            Component.onCompleted: {
                preferences.localStorageEnabled = true
                if (Qt.application.arguments[1].toString().indexOf(myUrl) > -1) {
                    console.warn("got argument: " + Qt.application.arguments[1])
                    url = Qt.application.arguments[1]
                }
                console.warn("url is: " + url)
            }
            onGeolocationPermissionRequested: { request.accept() }
            Loader {
                id: filePickerLoader
                source: "ContentPickerDialog.qml"
                asynchronous: true
            }
        }
        ThinProgressBar {
            webview: webview
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
        }
        RadialBottomEdge {
            id: nav
            visible: true
            actions: [
                RadialAction {
                    id: reload
                    iconName: "reload"
                    onTriggered: {
                        webview.reload()
                    }
                    text: qsTr("Reload")
                },
                RadialAction {
                    id: forward
                    enabled: webview.canGoForward
                    iconName: "go-next"
                    onTriggered: {
                        webview.goForward()
                    }
                   text: qsTr("Forward")
                 },
                RadialAction {
                    id: news
                    iconName: "stock_video"
                    onTriggered: {
                        webview.url = "http://news.orf.at/m/"
                    }
                    text: qsTr("News")
                },
                RadialAction {
                    id: wetter
                    iconName: "flash-on"
                    iconSource: Qt.resolvedUrl("icons/weather.svg")
                    onTriggered: {
                        webview.url = "http://wetter.orf.at/m/"
                    }
                    text: qsTr("Wetter")
                },
                RadialAction {
                    id: tel
                    iconName: "call-start"
                    iconSource: Qt.resolvedUrl("icons/phone.svg")
                    onTriggered: {
                        webview.url = "http://kundendienst.orf.at/"
                    }
                    text: qsTr("Kontakt")
                },
                RadialAction {
                    id: tv
                    iconName: "stock_video"
                    iconSource: Qt.resolvedUrl("icons/tv.svg")
                    onTriggered: {
                        webview.url = "http://tv.orf.at/m/"
                    }
                    text: qsTr("TV")
                },
                RadialAction {
                    id: radio
                    iconName: "location"
                    onTriggered: {
                        webview.url = "http://radio.orf.at/"
                    }
                    text: qsTr("Radio")
                },
                RadialAction {
                    id: hitradio
                    iconSource: Qt.resolvedUrl("icons/hitradio.svg")
                    onTriggered: {
                        webview.url = "http://oe3.orf.at/live/"
                    }
                    text: qsTr("Ö3 live")
                },
                RadialAction {
                    id: back
                    enabled: webview.canGoBack
                    iconName: "go-previous"
                    onTriggered: {
                        webview.goBack()
                    }
                    text: qsTr("Back")
                }
            ]
        }
    }
    Connections {
        target: Qt.inputMethod
        onVisibleChanged: nav.visible = !nav.visible
    }
    Connections {
        target: webview
        onFullscreenChanged: nav.visible = !webview.fullscreen
    }
    Connections {
        target: UriHandler
        onOpened: {
            if (uris.length === 0 ) {
                return;
            }
            webview.url = uris[0]
            console.warn("uri-handler request")
        }
    }
}
