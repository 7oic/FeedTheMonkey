import QtWebKit 3.0
import QtWebKit.experimental 1.0
import QtQuick 2.0
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.3
import QtQuick.Controls 1.3
import TTRSS 1.0

ScrollView {
    id: content
    property Post post
    property ApplicationWindow app

    property int textFontSize: 14
    property int scrollJump: 48
    property int pageJump: parent.height
    Layout.minimumWidth: 400
    onTextFontSizeChanged: webView.setDefaults()

    style: ScrollViewStyle {
        transientScrollBars: true
    }

    function scrollDown(jump) {
        if(!jump) {
            webView.experimental.evaluateJavaScript("window.scrollTo(0, document.body.scrollHeight - " + height + ");")
        } else {
            webView.experimental.evaluateJavaScript("window.scrollBy(0, " + jump + ");")
        }
    }

    function scrollUp(jump) {
        if(!jump) {
            webView.experimental.evaluateJavaScript("window.scrollTo(0, 0);")
        } else {
            webView.experimental.evaluateJavaScript("window.scrollBy(0, -" + jump + ");")
        }
    }

    function loggedOut() {
        post = null
    }

    Label { id: fontLabel }

    WebView {
        id: webView
        url: "../html/content.html"

        // Enable communication between QML and WebKit
        experimental.preferences.navigatorQtObjectEnabled: true;

        property Post post: content.post

        function setPost() {
            if(post) {
                experimental.evaluateJavaScript("setArticle(" + post.jsonString + ")")
            } else {
                experimental.evaluateJavaScript("setArticle('logout')")
            }
        }

        function setDefaults() {
            // font name needs to be enclosed in single quotes
            experimental.evaluateJavaScript("document.body.style.fontFamily = \"'" + fontLabel.font.family + "'\";");
            experimental.evaluateJavaScript("document.body.style.fontSize = '" + content.textFontSize + "pt';");
        }


        onNavigationRequested: {
            if (request.navigationType != WebView.LinkClickedNavigation) {
                request.action = WebView.AcceptRequest;
            } else {
                request.action = WebView.IgnoreRequest;
                Qt.openUrlExternally(request.url);
            }
        }

        onLoadingChanged: {
            if(loadRequest.status === WebView.LoadSucceededStatus) {
                setPost()
                setDefaults()
            }
        }

        onPostChanged: setPost()
        Keys.onPressed: app.keyPressed(event)
    }
}

