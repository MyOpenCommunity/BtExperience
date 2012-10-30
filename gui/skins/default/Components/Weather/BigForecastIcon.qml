import QtQuick 1.1
import Components.Text 1.0


Item {
    id: bigForecastIcon

    property string weather: "sunny"
    property string title: "Mostly cloudy"
    property string temperature: "15°"
    property int minDim: bigForecastIcon.width < bigForecastIcon.height ? bigForecastIcon.width : bigForecastIcon.height

    WeatherIcon {
        id: weatherIcon

        weather: bigForecastIcon.weather
        width: minDim
        height: minDim
        anchors.centerIn: parent
    }

    UbuntuLightText {
        id: dayText

        horizontalAlignment: Text.AlignHCenter
        anchors {
            top: weatherIcon.top
            topMargin: 5
            left: weatherIcon.left
            leftMargin: 5
        }
        text: bigForecastIcon.temperature
        font.pointSize: 28
    }

    UbuntuLightText {
        id: temperatureText

        horizontalAlignment: Text.AlignHCenter
        anchors {
            bottom: weatherIcon.bottom
            bottomMargin: 20
            right: weatherIcon.right
            rightMargin: 5
        }
        text: bigForecastIcon.title
        font.pointSize: 28
    }
}
