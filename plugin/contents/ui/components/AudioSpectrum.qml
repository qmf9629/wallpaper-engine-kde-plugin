import QtQuick 2.5
import com.github.catsout.wallpaperEngineKde 1.2 as NativePlugin

Item {
    id: root

    property alias active: spectrum.active
    signal frame(var audioArray)

    NativePlugin.AudioSpectrum {
        id: spectrum
        onFrame: (audioArray) => root.frame(audioArray)
    }
}
