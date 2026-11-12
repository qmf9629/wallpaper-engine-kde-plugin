import QtQuick 2.6
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.5

import ".."
import "../components"

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.4 as Kirigami


Flickable {
    // Наследуем тему от родителя
    Kirigami.Theme.inherit: true

    Layout.fillWidth: true
    ScrollBar.vertical: ScrollBar { id: scrollbar }
    //ScrollBar.horizontal: ScrollBar { }

    contentWidth: width - (scrollbar.visible ? scrollbar.width : 0)
    contentHeight: contentItem.childrenRect.height
    clip: true
    boundsBehavior: Flickable.OvershootBounds

    OptionGroup {
        id: option_group
        header.visible: false
        anchors.left: parent.left
        anchors.right: parent.right

        OptionItem {
            text: '使用说明'
            text_color: Kirigami.Theme.textColor
            icon: '../../images/information-outline.svg'

            contentBottom: ColumnLayout {
                Text {
                    Layout.fillWidth: true
                    color: Kirigami.Theme.disabledTextColor
                    text: `
                        <ol>
                        <li>在 Steam 中安装 <i>Wallpaper Engine</i></li>
                        <li>在创意工坊中订阅一些壁纸</li>
                        <li>打开“壁纸”页，程序会自动查找 <i>steamlibrary</i>
                            <ul>
                                <li>支持 Flatpak、Snap 安装，以及其他磁盘上的 Steam 库</li>
                                <li>如果没有找到，请点击文件夹按钮选择包含 <i>steamapps</i> 的目录</li>
                            </ul>
                        </li>
                        </ol>
                    `
                    wrapMode: Text.Wrap
                    textFormat: Text.RichText
                }
            }
        }
        OptionItem {
            visible: libcheck.wallpaper

            text: '修复启动崩溃'
            text_color: Kirigami.Theme.textColor
            icon: '../../images/information-outline.svg'
            contentBottom: ColumnLayout {
                Text {
                    Layout.fillWidth: true
                    color: Kirigami.Theme.disabledTextColor
                    text: `
                        <ol>
                        <li>删除 <b>~/.config/plasma-org.kde.plasma.desktop-appletsrc</b> 中的 <i>WallpaperSource</i> 配置行</li>
                        <li>重启 KDE</li>
                        </ol>
                    `
                    wrapMode: Text.Wrap
                    textFormat: Text.RichText
                }
            }
        }
        OptionItem {
            icon: '../../images/github.svg'
            text: 'GitHub 项目'
            text_color: Kirigami.Theme.textColor
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                cursorShape: Qt.PointingHandCursor
                onClicked: Qt.openUrlExternally(Common.repo_url)
            }
        }

        OptionItem {
            text: '版本信息'
            text_color: Kirigami.Theme.textColor
            icon: '../../images/tag.svg'
            contentBottom: ColumnLayout {
                Text {
                    Layout.fillWidth: true
                    color: Kirigami.Theme.disabledTextColor
                    text: `
                        <ul>
                        <li>插件：${Common.version}</li>
                        <li>插件库：${plugin_info.version}</li>
                        ${Common.version != plugin_info.version ? "<br><b>警告：插件库版本与插件版本不一致</b>" : ""}
                        <li>KDE：${Qt.application.version}</li>
                        <li>文件助手：原生实现</li>
                        </ul>
                    `
                    wrapMode: Text.Wrap
                    textFormat: Text.RichText
                }
            }
        }

        OptionItem {
            text: '依赖检查'
            text_color: Kirigami.Theme.textColor
            icon: '../../images/checkmark.svg'
            contentBottom: ListView {
                implicitHeight: contentItem.childrenRect.height

                model: ListModel {}
                clip: false
                property var modelraw: {
                    const _model = [
                        {
                            ok: libcheck.qtwebchannel,
                            name: "qtwebchannel（QML，网页壁纸所需）"
                        },
                        {
                            ok: libcheck.wallpaper,
                            name: "插件库（场景和 MPV 后端所需）"
                        }
                    ];
                    return _model;
                }
                onModelrawChanged: {
                    this.model.clear();
                    this.modelraw.forEach((el) => {
                        this.model.append(el);
                    });
                }
                delegate: CheckBox {
                    text: name
                    checked: ok
                    enabled: false
                    contentItem: Text {
                        text: parent.text
                        color: Kirigami.Theme.disabledTextColor
                        leftPadding: parent.indicator.width + parent.spacing
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }
}
