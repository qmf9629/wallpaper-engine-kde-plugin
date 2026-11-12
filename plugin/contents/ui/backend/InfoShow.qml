import QtQuick 2.5
import QtQuick.Layouts 1.2
import ".."

Item {
    id: infoItem
    anchors.fill: parent
    property string info: "未知错误"
    property string type: "unknown"
    property string wid: "未知"
    property string source
    GridLayout {
        id: configRow
        columns: 1
        rows: 1
        anchors.fill: parent
        Text {
            Layout.alignment: Qt.AlignCenter
            Layout.preferredWidth: infoItem.width * 0.7
            text: [
            `创意工坊 ID：${infoItem.wid}`,
            `类型：${Common.typeLabel(infoItem.type)}`,
            `信息：${infoItem.info}`
            ].join("\n");
            color: "yellow"
            wrapMode: Text.Wrap
            elide: Text.ElideRight 
            font.pointSize: 30
        }
    }
    Component.onCompleted:{
        background.nowBackend = "InfoShow";
    }

    function play(){}

    function pause(){}
    function getMouseTarget() {}
}
