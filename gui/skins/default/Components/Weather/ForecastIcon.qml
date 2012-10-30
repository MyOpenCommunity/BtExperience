import QtQuick 1.1
import Components.Text 1.0


Item {
    id: forecastIcon

    property string weather: "sunny"
    property string day: "Mon"
    property string temperature: "15°"
    property int minDim: forecastIcon.width < forecastIcon.height ? forecastIcon.width : forecastIcon.height

    WeatherIcon {
        id: weatherIcon

        weather: forecastIcon.weather
        width: minDim
        height: minDim
        anchors.centerIn: parent
    }

    UbuntuLightText {
        id: dayText

        horizontalAlignment: Text.AlignHCenter
        anchors {
            top: weatherIcon.top
            topMargin: weatherIcon.height / 5 - dayText.paintedHeight
            left: weatherIcon.left
            right: weatherIcon.right
        }
        text: forecastIcon.day
    }

    UbuntuLightText {
        id: temperatureText

        horizontalAlignment: Text.AlignHCenter
        anchors {
            bottom: weatherIcon.bottom
            bottomMargin: weatherIcon.height / 5 - temperatureText.paintedHeight
            left: weatherIcon.left
            right: weatherIcon.right
        }
        text: forecastIcon.temperature
    }
}
