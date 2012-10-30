import QtQuick 1.1
import Components 1.0


SvgImage {
    id: weatherIcon

    property string weather: "na"
    property variant fileNames: {
        "blizzard": "blizzard.png",
                "blowing-snow": "blowing-snow.png",
                "chance-storm-n": "chance-storm-n.png",
                "chance-storm": "chance-storm.png",
                "cloudy": "cloudy.png",
                "drizzle": "drizzle.png",
                "fair-drizzle": "fair-drizzle.png",
                "fair": "fair.png",
                "flurries": "flurries.png",
                "fog": "fog.png",
                "freezing-rain": "freezing-rain.png",
                "hazy": "hazy.png",
                "m-cloudy-night": "m-cloudy-night.png",
                "m-cloudy": "m-cloudy.png",
                "m-c-night-rain": "m-c-night-rain.png",
                "m-c-night-snow": "m-c-night-snow.png",
                "m-c-rain": "m-c-rain.png",
                "m-c-snow": "m-c-snow.png",
                "moon": "moon.png",
                "na": "na.png",
                "partly-cloudy": "partly-cloudy.png",
                "p-c-night": "p-c-night.png",
                "p-c-night-rain": "p-c-night-rain.png",
                "p-c-night-snow": "p-c-night-snow.png",
                "p-c-rain": "p-c-rain.png",
                "p-c-snow": "p-c-snow.png",
                "rainy": "rainy.png",
                "rainy-snow": "rainy-snow.png",
                "showers": "showers.png",
                "sleet": "sleet.png",
                "smoke": "smoke.png",
                "snow": "snow.png",
                "snow-shower": "snow-shower.png",
                "sunny": "sunny.png",
                "thunder-storm": "thunder-storm.png",
                "t-storm-rain": "t-storm-rain.png",
                "wind": "wind.png",
                "w-s-warning": "w-s-warning.png",
                "w-s-watch": "w-s-watch.png"
    }

    source: "../../images/weather/" + fileNames[weatherIcon.weather]
    smooth: true
}
