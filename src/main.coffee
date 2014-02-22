Detector = require('Detector')
App = require('./app.coffee')
DetectMobile = require('./detectmobile.coffee')

if Detector.webgl and DetectMobile.any() is null
	new App()
else
	intro = document.getElementById('intro')
	intro.innerHTML = "This website doesn't work on mobile devices.<br>Please check out with PC or Mac version of Google Chrome or Firefox."


