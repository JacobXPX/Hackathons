---
output: html_document
---
### Smart Wake

  * `Light up a day!`


Has this ever happened to you ?: sometimes when you woke up in bed in the morning, instead of feeling refreshed, you felt tired and exhausted. Most of us choose to set alarm clocks according to our life schedules, i.e. going to class, meetings. Around 70% people forced themselves to wake up to meet social needs (Till Roenneberg). Meanwhile, some researchers (Charles Czeisler and Megan Jewett) found that it takes around two hours to recover from the exhausted status if you wake up at the wrong time.

During a thousand years' process of evolution, human bodies got adapted to the environment and became sensitive to daylight. Smart Wake is a web app built with R Shiny that offers a way to determine the right time to wake up every morning.

Smart Wake pulls weather data from AccuWeather and feeds into a model which takes solar radiance, whether it will be rainy and other factors into account to estimate the level of intensity of sunlight in a specific city at a specific time and date. 

_TL, DR_:

In Smart Wake, just drag the bar and choose to the level of sunlight to which you would like to wake up to. After setting an upper limit and a lower limit, it computes the corresponding time for the alarm clock.

Moreover, with more and more data from the user, such as sleeping cycle, Smart Wake gets better and better at its job. The app will keep track of user feedback so that it can deliver better recommendation on when to wake up.
