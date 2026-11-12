import QtQuick 2.6
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.5 as QSMat
import QtQuick.Layouts 1.5

import ".."
import "../components"
import "../js/utils.mjs" as Utils

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.6 as Kirigami
import com.github.catsout.wallpaperEngineKde

Flickable {
    id: settingTab

    // Наследуем тему от родителя
    Kirigami.Theme.inherit: true

    GlobalConfig {
        id: globalCfg
    }

    property alias cfg_Fps: sliderFps.value
    property alias cfg_Volume: sliderVol.value
    property alias cfg_MpvStats: ckbox_mpvStats.checked
    property alias cfg_SceneCachePasses: ckbox_cacheScenePasses.checked
    property alias cfg_ShareGpuContext: ckbox_shareGpuContext.checked
    property alias cfg_MirrorScene: ckbox_mirrorScene.checked
    property alias cfg_SpanScreens: ckbox_spanScreens.checked
    property string cfg_MpvHwdec
    property alias cfg_Speed: spin_speed.dValue
    property alias cfg_MuteAudio: ckbox_muteAudio.checked
    property alias cfg_MouseInput: ckbox_mouseInput.checked
    property alias cfg_ResumeTime: resumeSpin.value
    property alias cfg_SwitchTimer: randomSpin.value
    property alias cfg_RandomizeWallpaper: ckbox_randomizeWallpaper.checked
    property alias cfg_NoRandomWhilePaused: ckbox_noRandomWhilePaused.checked
    property alias cfg_GlobalMode: ckbox_globalMode.checked
    property alias cfg_PauseFilterByScreen: ckbox_pauseFilterByScreen.checked

    property alias cfg_PauseOnBatPower: chkbox_pauseOnBatPower.checked
    property alias cfg_PauseBatPercent: spin_pauseBatPercent.value

    property alias cfg_PauseOnGamemode: chkbox_pauseOnGameMode.checked

    Layout.fillWidth: true
    ScrollBar.vertical: ScrollBar { id: scrollbar }

    contentWidth: width - (scrollbar.visible ? scrollbar.width : 0)
    contentHeight: contentItem.childrenRect.height
    clip: true
    boundsBehavior: Flickable.OvershootBounds

    OptionGroup {
        header.visible: false
        anchors.left: parent.left
        anchors.right: parent.right


        OptionGroup {
            Layout.fillWidth: true
            header.text: '常规选项'
            header.text_color: Kirigami.Theme.textColor
            header.icon: '../../images/cheveron-down.svg'
            header.color: Kirigami.Theme.activeBackgroundColor

            OptionItem {
                text: '暂停播放'
                text_color: Kirigami.Theme.textColor
                icon: '../../images/pause.svg'
                actor:  ComboBox {
                    id: pauseMode
                    model: [
                        {
                            text: "有焦点或最大化的窗口",
                            value: Common.PauseMode.FocusOrMax
                        },
                        {
                            text: "有焦点的窗口",
                            value: Common.PauseMode.Focus
                        },
                        {
                            text: "最大化的窗口",
                            value: Common.PauseMode.Max
                        },
                        {
                            text: "全屏窗口",
                            value: Common.PauseMode.FullScreen
                        },
                        {
                            text: "任意窗口",
                            value: Common.PauseMode.Any
                        },
                        {
                            text: "从不",
                            value: Common.PauseMode.Never
                        }
                    ]
                    textRole: "text"
                    onActivated: cfg_PauseMode = Common.cbCurrentValue(this)
                    Component.onCompleted: currentIndex = Common.cbIndexOfValue(this, cfg_PauseMode)
                }
                contentBottom: ColumnLayout {
                    Text {
                        Layout.fillWidth: true
                        color: Kirigami.Theme.disabledTextColor
                        text: "检测到符合条件的窗口时自动暂停壁纸播放"
                        wrapMode: Text.Wrap
                    }
               }
            }
            OptionItem {
                text: '仅响应当前屏幕上的窗口'
                text_color: Kirigami.Theme.textColor
                actor: Switch {
                    id: ckbox_pauseFilterByScreen
                }
                contentBottom: ColumnLayout {
                    Text {
                        Layout.fillWidth: true
                        color: Kirigami.Theme.disabledTextColor
                        wrapMode: Text.Wrap
                        text: "按焦点或最大化窗口暂停时，忽略其他屏幕上的窗口"
                    }
                }
            }
            OptionItem {
                text: '使用电池供电时暂停'
                text_color: Kirigami.Theme.textColor
                actor: Switch {
                    id: chkbox_pauseOnBatPower
                }
            }
            OptionItem {
                // Independent of "pause on battery power": the runtime applies this
                // threshold on its own (0 = off), so keep it reachable to reset.
                text: '电量低于此值时暂停'
                text_color: Kirigami.Theme.textColor
                actor: RowLayout {
                    SpinBox {
                        id: spin_pauseBatPercent
                        from: 0
                        to: 100
                        stepSize: 1
                    }
                    Label { text: " %"; color: Kirigami.Theme.textColor }
                }
            }
            OptionItem {
                text: '游戏模式启动时暂停'
                text_color: Kirigami.Theme.textColor
                actor: Switch {
                    id: chkbox_pauseOnGameMode
                }
            }
            OptionItem {
                text: '显示模式'
                text_color: Kirigami.Theme.textColor
                icon: '../../images/window.svg'
                actor: ComboBox {
                    id: displayMode
                    model: [
                        {
                            text: "保持宽高比",
                            value: Common.DisplayMode.Aspect
                        },
                        {
                            text: "缩放并裁剪",
                            value: Common.DisplayMode.Crop
                        },
                        {
                            text: "缩放填满",
                            value: Common.DisplayMode.Scale
                        },
                    ]
                    textRole: "text"
                    onActivated: cfg_DisplayMode = Common.cbCurrentValue(this)
                    Component.onCompleted: currentIndex = Common.cbIndexOfValue(this, cfg_DisplayMode)
                }
            }

            OptionItem {
                text: '跨屏显示'
                text_color: Kirigami.Theme.textColor
                icon: '../../images/window.svg'
                actor: Switch {
                    id: ckbox_spanScreens
                }
                contentBottom: Text {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    color: Kirigami.Theme.disabledTextColor
                    text: "让每个屏幕显示完整桌面壁纸中的对应部分。启用“所有屏幕使用相同壁纸”以获得连续画面。"
                }
            }

            OptionItem {
                text: '恢复播放延迟'
                text_color: Kirigami.Theme.textColor
                icon: '../../images/timer.svg'
                actor: RowLayout {
                    spacing: 0
                    RowLayout {
                        SpinBox {
                            id: resumeSpin
                            from: 1
                            to: 60*1000
                            stepSize: 50
                        }
                        Label { text: " 毫秒"; color: Kirigami.Theme.textColor }
                    }
                }
                contentBottom: ColumnLayout {
                    Text {
                        Layout.fillWidth: true
                        color: Kirigami.Theme.disabledTextColor
                        text: "暂停后等待多久再恢复播放"
                    }
                }
            }
            OptionItem {
                text: '定时随机切换'
                text_color: Kirigami.Theme.textColor
                icon: '../../images/time.svg'
                actor: Switch {
                    id: ckbox_randomizeWallpaper
                }
                contentBottom: ColumnLayout {
                    Text {
                        Layout.fillWidth: true
                        color: Kirigami.Theme.disabledTextColor
                        text: "在“壁纸”页面筛选出的壁纸中随机切换"
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        visible: ckbox_randomizeWallpaper.checked
                        Label {
                            id:heightpicker
                            text: "切换间隔："
                            color: Kirigami.Theme.textColor
                        }
                        SpinBox {
                            id: randomSpin
                            width: font.pixelSize * 4
                            from: 1
                            to: 60*24*30
                            stepSize: 1
                        }
                        Label { text: " 分钟"; color: Kirigami.Theme.textColor }
                        Item { Layout.fillWidth: true }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        visible: ckbox_randomizeWallpaper.checked
                        Label {
                            id: randomWhilePausedSetter
                            text: "壁纸暂停时不随机切换  "
                            color: Kirigami.Theme.textColor
                        }
                        Switch {
                            id: ckbox_noRandomWhilePaused
                        }
                    }
                }
            }

            OptionItem {
                text: '所有屏幕使用相同壁纸'
                text_color: Kirigami.Theme.textColor
                icon: '../../images/window.svg'
                actor: Switch {
                    id: ckbox_globalMode
                    // reflect the real shared state, not this screen's stale copy
                    Component.onCompleted: checked = globalCfg.enabled
                }
                contentBottom: Text {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    color: Kirigami.Theme.disabledTextColor
                    text: "在所有屏幕间共享壁纸选择和随机切换设置 "
                        + "(one configuration for the whole system). Press Apply to take effect."
                }
            }

            OptionItem {
                text: "播放速度"
                text_color: Kirigami.Theme.textColor
                icon: '../../images/fast-forward.svg'
                actor: RowLayout {
                    DoubleSpinBox {
                        id: spin_speed
                        dFrom: 0.1
                        dTo: 16.0
                        dStepSize: 0.1
                    }
                }
            }


            OptionItem {
                text: "静音"
                text_color: Kirigami.Theme.textColor
                icon: ckbox_muteAudio.checked
                    ? '../../images/volume-off.svg'
                    : '../../images/volume-up.svg'
                actor: Switch {
                    id: ckbox_muteAudio
                }
            }
            OptionItem {
                text: "音量"
                text_color: Kirigami.Theme.textColor
                visible: !cfg_MuteAudio
                actor: RowLayout {
                    Layout.preferredWidth: displayMode.width
                    Label {
                        Layout.preferredWidth: font.pixelSize * 2
                        text: sliderVol.value.toString()
                        color: Kirigami.Theme.textColor
                    }
                    Slider {
                        id: sliderVol
                        Layout.fillWidth: true
                        from: 0
                        to: 100
                        stepSize: 5.0
                        snapMode: Slider.SnapOnRelease
                    }
                }
            }

            OptionItem {
                visible: libcheck.wallpaper
                text_color: Kirigami.Theme.textColor
                text: "鼠标输入"
                icon: '../../images/mouse.svg'
                actor: Switch {
                    id: ckbox_mouseInput
                }
            }
       }

        OptionGroup {
            Layout.fillWidth: true

            header.text: '视频选项'
            header.text_color: Kirigami.Theme.textColor
            header.icon: '../../images/cheveron-down.svg'
            header.color: Kirigami.Theme.activeBackgroundColor

            OptionItem {
                text: '视频后端'
                text_color: Kirigami.Theme.textColor
                icon: '../../images/plugin.svg'
                actor: ComboBox {
                    model: [
                        {
                            text: "QtMultimedia",
                            value: Common.VideoBackend.QtMultimedia,
                            enabled: true
                        },
                        {
                            text: "Mpv",
                            value: Common.VideoBackend.Mpv,
                            enabled: libcheck.wallpaper
                        }
                    ].filter(el => el.enabled)
                    textRole: "text"
                    onActivated: cfg_VideoBackend = Common.cbCurrentValue(this)
                    Component.onCompleted: currentIndex = Common.cbIndexOfValue(this, cfg_VideoBackend)
                }
            }

            OptionItem {
                text: '显示 MPV 统计信息'
                text_color: Kirigami.Theme.textColor
                icon: '../../images/information-outline.svg'
                visible: cfg_VideoBackend == Common.VideoBackend.Mpv
                actor: Switch {
                    id: ckbox_mpvStats
                }
            }

            OptionItem {
                text: '硬件解码'
                text_color: Kirigami.Theme.textColor
                icon: '../../images/plugin.svg'
                visible: cfg_VideoBackend == Common.VideoBackend.Mpv
                actor: ComboBox {
                    id: cbox_mpvHwdec
                    model: [
                        { text: "自动",     value: "auto" },
                        { text: "软件解码", value: "no"   }
                    ]
                    textRole: "text"
                    onActivated: cfg_MpvHwdec = model[currentIndex].value
                    Component.onCompleted: {
                        for (let i = 0; i < model.length; i++) {
                            if (model[i].value === cfg_MpvHwdec) {
                                currentIndex = i;
                                break;
                            }
                        }
                    }
                }
            }
        }
        OptionGroup {
            Layout.fillWidth: true

            header.text: '场景选项'
            header.text_color: Kirigami.Theme.textColor
            header.icon: '../../images/cheveron-down.svg'
            header.color: Kirigami.Theme.activeBackgroundColor
            visible: libcheck.wallpaper

            OptionItem {
                text: '帧率上限'
                text_color: Kirigami.Theme.textColor
                icon: '../../images/tuning.svg'
                actor: RowLayout {
                    Label {
                        Layout.preferredWidth: font.pixelSize * 2
                        text: sliderFps.value.toString()
                        color: Kirigami.Theme.textColor
                    }
                    Slider {
                        id: sliderFps
                        Layout.fillWidth: true
                        from: 5
                        to: 60
                        stepSize: 1.0
                        snapMode: Slider.SnapOnRelease
                    }
                }
                contentBottom: ColumnLayout {
                    Text {
                        Layout.fillWidth: true
                        color: Kirigami.Theme.disabledTextColor
                        text: "低：10，中：15，高：25，超高：30"
                    }
                }

            }
            OptionItem {
                text: '缓存静态图层'
                text_color: Kirigami.Theme.textColor
                icon: '../../images/tuning.svg'
                actor: Switch {
                    id: ckbox_cacheScenePasses
                }
                contentBottom: ColumnLayout {
                    Text {
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap
                        color: Kirigami.Theme.disabledTextColor
                        text: "静态图层（例如模糊背景）只渲染一次，而不是每帧重复渲染，可节省 CPU/GPU 资源。若壁纸显示异常，请关闭此选项。"
                    }
                }
            }
            OptionItem {
                text: '跨屏共享 GPU'
                text_color: Kirigami.Theme.textColor
                icon: '../../images/tuning.svg'
                actor: Switch {
                    id: ckbox_shareGpuContext
                }
                contentBottom: ColumnLayout {
                    Text {
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap
                        color: Kirigami.Theme.disabledTextColor
                        text: "多屏使用相同壁纸时，共用一个 GPU 设备并只加载一份纹理，以节省显存。重新加载壁纸后生效。"
                    }
                }
            }
            OptionItem {
                text: '跨屏镜像场景'
                text_color: Kirigami.Theme.textColor
                icon: '../../images/tuning.svg'
                actor: Switch {
                    id: ckbox_mirrorScene
                }
                contentBottom: ColumnLayout {
                    Text {
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap
                        color: Kirigami.Theme.disabledTextColor
                        text: "多屏显示相同场景壁纸时，只渲染一次并镜像到其他屏幕，以节省显存。会跳过需要响应鼠标的壁纸，重新加载后生效。"
                    }
                }
            }
            OptionItem {
                text: '着色器缓存'
                text_color: Kirigami.Theme.textColor
                icon: '../../images/information-outline.svg'
                actor: Kirigami.ActionToolBar {
                    Layout.fillWidth: true
                    alignment: Qt.AlignRight
                    flat: false
                    actions: [
                        Kirigami.Action {
                            text: '打开'
                            tooltip: '在文件管理器中打开'
                            onTriggered: {
                                if(plugin_info.cache_path)
                                    Qt.openUrlExternally(plugin_info.cache_path);
                            }
                        }
                    ]
                }
                contentBottom: ColumnLayout {
                    Text {
                        Layout.fillWidth: true
                        property string cache_path: Common.urlNative(plugin_info.cache_path)

                        color: Kirigami.Theme.disabledTextColor
                        text: plugin_info.cache_path
                        ? `${cache_path} - ${cache_size}`
                        : `Not available`

                        property string cache_size: {
                            if(pyext) {
                                pyext.get_dir_size(this.cache_path).then(res => {
                                    this.cache_size = Utils.prettyBytes(res);
                                }).catch(reason => console.error(reason));
                            }
                            return "? MB";
                        }
                    }
                }
            }
        }
    }


}

