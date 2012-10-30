import QtQuick 1.1
import Components.Text 1.0
import Components.Weather 1.0


Page {
    id: page

    property int controlWidth: 300
    property int controlHeight: 450

    source: "images/multimedia.jpg"
    text: qsTr("multimedia")
    state: "loading"

    Timer {
        interval: 1000
        running: true
        onTriggered: {
            state = "ready"
            running = false
        }
    }

    Rectangle {
        id: wait

        color: "white"
        anchors {
            top: toolbar.bottom
            topMargin: 35
            left: navigationBar.right
            leftMargin: 100
        }
        width: page.controlWidth
        height: page.controlHeight

        UbuntuLightText {
            text: qsTr("Loading weather data...")
            font.pointSize: 18
            anchors.centerIn: parent
        }
    }

    Rectangle {
        id: main

        color: "white"
        anchors {
            top: toolbar.bottom
            topMargin: 35
            left: navigationBar.right
            leftMargin: 100
        }
        width: page.controlWidth
        height: page.controlHeight

        Column {
            spacing: 6
            anchors.fill: parent

            Rectangle {
                width: parent.width
                height: 25
                color: "lightgrey"

                Text {
                    text: "Erba, CO, Italy"
                    //                    text: (model.hasValidCity ? model.city : "Unknown location") + (model.useGps ? " (GPS)" : "")
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            BigForecastIcon {
                id: current

                width: parent.width
                height: parent.width

                weather: "sunny"
                temperature: "13°"
                title: "Sunny"
                //                weather: (model.hasValidWeather
                //                          ? model.weather.weather
                //                          : "sunny")
                //                topText: (model.hasValidWeather
                //                          ? model.weather.tempString
                //                          : "??")
                //                bottomText: (model.hasValidWeather
                //                             ? model.weather.weatherDesc
                //                             : "No weather data")
            }

            Row {
                id: iconRow
                spacing: 6

                width: parent.width
                height: parent.height / 3

                property int iconWidth: iconRow.width / 4 - 5
                property int iconHeight: iconRow.height

                ForecastIcon {
                    id: forecast1
                    width: iconRow.iconWidth
                    height: iconRow.iconHeight

                    day: "Mon"
                    temperature: "5°/15°"
                    weather: "showers"
                    //                    topText: (model.hasValidWeather ?
                    //                                  model.forecast[0].dayOfWeek : "??")
                    //                    bottomText: (model.hasValidWeather ?
                    //                                     model.forecast[0].tempString : "??/??")
                    //                    weather: (model.hasValidWeather ?
                    //                                  model.forecast[0].weather : "showers")
                }
                ForecastIcon {
                    id: forecast2
                    width: iconRow.iconWidth
                    height: iconRow.iconHeight

                    day: "Tue"
                    temperature: "6°/15°"
                    weather: "snow"
                    //                    topText: (model.hasValidWeather ?
                    //                                  model.forecast[1].dayOfWeek : "??")
                    //                    bottomText: (model.hasValidWeather ?
                    //                                     model.forecast[1].tempString : "??/??")
                    //                    weather: (model.hasValidWeather ?
                    //                                  model.forecast[1].weather : "showers")
                }
                ForecastIcon {
                    id: forecast3
                    width: iconRow.iconWidth
                    height: iconRow.iconHeight

                    day: "Wed"
                    temperature: "5°/16°"
                    weather: "t-storm-rain"
                    //                    topText: (model.hasValidWeather ?
                    //                                  model.forecast[2].dayOfWeek : "??")
                    //                    bottomText: (model.hasValidWeather ?
                    //                                     model.forecast[2].tempString : "??/??")
                    //                    weather: (model.hasValidWeather ?
                    //                                  model.forecast[2].weather : "showers")
                }
                ForecastIcon {
                    id: forecast4
                    width: iconRow.iconWidth
                    height: iconRow.iconHeight

                    day: "Thu"
                    temperature: "5°/15°"
                    weather: "m-cloudy"
                    //                    topText: (model.hasValidWeather ?
                    //                                  model.forecast[3].dayOfWeek : "??")
                    //                    bottomText: (model.hasValidWeather ?
                    //                                     model.forecast[3].tempString : "??/??")
                    //                    weather: (model.hasValidWeather ?
                    //                                  model.forecast[3].weather : "showers")
                }

            }
        }
    }

    states: [
        State {
            name: "loading"
            PropertyChanges { target: main; opacity: 0 }
            PropertyChanges { target: wait; opacity: 1 }
        },
        State {
            name: "ready"
            PropertyChanges { target: main; opacity: 1 }
            PropertyChanges { target: wait; opacity: 0 }
        }
    ]

    transitions: [
        Transition {
            NumberAnimation { property: "opacity"; duration: 400 }
        }
    ]
}
