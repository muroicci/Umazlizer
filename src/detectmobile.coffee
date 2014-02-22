
module.exports = 
    class DetectMobile

        @Android: ->
            navigator.userAgent.match(/Android/i)

        @BlackBerry: ->
            navigator.userAgent.match(/BlackBerry/i)

        @iOS: ->
            navigator.userAgent.match(/iPhone|iPad|iPod/i)

        @Opera: ->
            navigator.userAgent.match(/Opera Mini/i)

        @Windows: ->
            navigator.userAgent.match(/IEMobile/i)

        @any: ->
            (DetectMobile.Android() or DetectMobile.BlackBerry() or DetectMobile.iOS() or DetectMobile.Opera() or DetectMobile.Windows())
