
clm = require('clm')
pModel = require('pModel')

TweenLite = require('TweenLite')
require('CSSPlugin')
require('EasePack')

THREE = require('THREE')

HorseHead = require('./horsehead.coffee')
FacePosition = require('./faceposition.coffee')

Stats = require('Stats')
dat = require('datgui')

navigator.getUserMedia = navigator.getUserMedia or navigator.webkitGetUserMedia or navigator.mozGetUserMedia or navigator.msGetUserMedia;
window.URL = window.URL or window.webkitURL or window.msURL or window.mozURL;

module.exports =

	class App


		constructor: ->
			@videoWidth = 320
			@videoHeight = 240
			@debug = false
			@wrapper = document.getElementById('wrapper')
			@logo = document.getElementsByTagName('header')[0]
			@intro = document.getElementById('intro')
			@cta = document.getElementById('cta')
			@info = document.getElementById('info')
			@arrow = document.getElementById('arrow')
			@videoContainer = document.getElementById('videoContainer')
			@videoContainer.style.display = 'none'
			@initIntro()

		initIntro: =>

			handlerClick = (evt)=>
				@initVideo()
				@logo.style.cursor = @cta.style.cursor = 'auto'
				@logo.removeEventListener('click', handlerClick)
				@cta.removeEventListener('click', handlerClick)
				@logo.removeEventListener( 'mouseover', handlerMouseover )
				@cta.removeEventListener( 'mouseover', handlerMouseover )
				@logo.removeEventListener( 'mouseout', handlerMouseout )
				@cta.removeEventListener( 'mouseout', handlerMouseout )

			handlerMouseover = (evt)=>
				TweenLite.to( @logo, 0.5, {scaleX:1.2, scaleY:1.2})
				TweenLite.to( @intro, 0.5, {scaleX:1.2, scaleY:1.2})
			handlerMouseout = (evt)=>
				TweenLite.to( @logo, 0.5, {scaleX:1.0, scaleY:1.0})
				TweenLite.to( @intro, 0.5, {scaleX:1.0, scaleY:1.0})

			@logo.addEventListener( 'click', handlerClick )
			@cta.addEventListener( 'click', handlerClick )
			@logo.addEventListener( 'mouseover', handlerMouseover )
			@cta.addEventListener( 'mouseover', handlerMouseover )
			@logo.addEventListener( 'mouseout', handlerMouseout )
			@cta.addEventListener( 'mouseout', handlerMouseout )
			@logo.style.cursor = @cta.style.cursor = 'pointer'

		initDebug: =>

			@debug = true

			@stats = new Stats()
			document.body.appendChild(@stats.domElement)

			@gui = new dat.GUI()
			@gui.add(@horseHead.modelParams, 'x', -2000, 2000).onChange => @horseHead.update()
			@gui.add(@horseHead.modelParams, 'y', -2000, 2000).onChange => @horseHead.update()
			@gui.add(@horseHead.modelParams, 'z', -2000, 2000).onChange => @horseHead.update()
			@gui.add(@horseHead.modelParams, 'scale', -20, 20).onChange => @horseHead.update()

			@overlay = document.createElement("canvas")
			@overlay.width = @videoWidth
			@overlay.height = @videoHeight
			@overlay.style.position = 'absolute'
			document.getElementById('videoContainer').appendChild(@overlay)
			@overlayCC = @overlay.getContext("2d")


		initVideo: =>

			complete = =>
				@inputVideo = document.createElement("video")
				@inputVideo.width = @videoWidth
				@inputVideo.height = @videoHeight
				@inputVideo.style.position = 'absolute'
				@inputVideo.loop = true
				@videoContainer.appendChild(@inputVideo)


				@ctrack = new clm.tracker({useWebGL:true})
				@ctrack.init(pModel)

				@facePosition = new FacePosition(@inputVideo, @ctrack)


				#  check for camerasupport
				if (navigator.getUserMedia) 
					videoSelector = {video : true};
					if window.navigator.appVersion.match(/Chrome\/(.*?) /)
						chromeVersion = parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10)
						if chromeVersion < 20 
							videoSelector = "video"
				
					navigator.getUserMedia(videoSelector, ( stream )=>
						if @inputVideo.mozCaptureStream
							@inputVideo.mozSrcObject = stream
						else
							@inputVideo.src = (window.URL && window.URL.createObjectURL(stream)) || stream
						@initScene()
						# @initDebug()

					, -> 
						alert("Your browser does not seem to support camera. View on the latest version of Google Chrome or Firefox.")
					)
				else
					alert("Your browser does not seem to support camera. View on the latest version of Google Chrome or Firefox.");
				
			# animation
			@intro.remove()
			@info.style.display = 'block'
			TweenLite.fromTo(@info, 0.75, {
				y: window.innerHeight/2 + 600
				rotation:60
			},
			{
				y: 50
				delay:0.25
				rotation:0
				ease: Back.easeOut
			})

			is_chrome = navigator.userAgent.toLowerCase().indexOf('chrome') > -1
			if is_chrome then @arrow.style.display = 'block'

			TweenLite.to(@logo, 1, {
				scaleX:0.5 
				scaleY:0.5
				x:-260
				y:-280
				rotation: -5
				ease:Elastic.easeOut
				onComplete: complete
			})


		initScene: =>

			@info.style.display = 'none'
			@arrow.remove()

			@scene = new THREE.Scene()
			@camera = new THREE.PerspectiveCamera( 45, @videoWidth/@videoHeight, 1, 1000 )
			@camera.position.z = 400
			@renderer = new THREE.WebGLRenderer( 
				atialias: true
				alpha: true
				preserveDrawingBuffer: true
			)
			@renderer.setSize(@videoWidth*2, @videoHeight*2)
			@renderer.setClearColor( 0x000000, 0)
			@renderer.shadowMapEnabled = true
			@renderer.shadowMapCullFace = THREE.CullFaceBack
			@renderer.gammaInput = true
			@renderer.gammaOutput = true
			@renderer.physicallyBasedShading = true

			dom = @renderer.domElement
			dom.style.position = 'absolute'
			dom.style.left = "-#{@videoWidth*0.5}px"
			dom.style.top = "-#{@videoHeight*0.5}px"
			dom.style.webkitTransform = dom.style.mozTransform = dom.style.msTransform = dom.style.transform = "scale(0.5,0.5)"
			@videoContainer.appendChild(dom)

			params = 
				x:0
				y:-20
				z:-150
				scale:12

			@horseHead = new HorseHead(params)
			@scene.add(@horseHead)
			@horseHead.addEventListener( 'ready', (evt)=> 
				@createUI() 
				@startVideo()
			)

			dlight = new THREE.DirectionalLight(0xffffff,1)
			dlight.position.set(1, 1, 2)
			dlight.position.multiplyScalar(400)
			dlight.lookAt(@scene.position)
			dlight.castShadow = true
			dlight.shadowMapWidth = 1024
			dlight.shadowMapHeight = 1024
			dlight.shadowCameraLeft = -500
			dlight.shadowCameraRight = 500
			dlight.shadowCameraTop = 500
			dlight.shadowCameraBottom = -500
			dlight.shadowCameraFar = 3500
			dlight.shadowBias = -0.0001
			dlight.shadowDarkness = 0.25
			@scene.add(dlight)


			hemiLight = new THREE.HemisphereLight( 0xffffff, 0xffffff, 0.6 );
			hemiLight.color.setHSL(28/360,12/100,95/100)
			hemiLight.groundColor.setHSL(241/360,38/100,85/100)
			hemiLight.position.set(0,500,0)
			@scene.add(hemiLight)



		startVideo: =>
			@videoContainer.style.display = "block"
			@inputVideo.play()
			@ctrack.start(@inputVideo)
			@render()

		createUI: =>

			container = document.createElement('div')
			container.id = 'colorNav'

			createRadioButton = (id, value, label, checked=false)->
				rdo = document.createElement('input')
				rdo.id = id
				rdo.type = 'radio'
				rdo.checked = checked
				rdo.name = 'horseMaterial'
				rdo.value = value
				lbl = document.createElement('label')
				lbl.htmlFor = rdo.id
				lbl.innerHTML = label
				container.appendChild(rdo)
				container.appendChild(lbl)
				return rdo


			r1 = createRadioButton('horseMatRadio1', 'normal', 'Normal', true)
			r1.onchange = =>
				@horseHead.changeMaterial('normal')
			r2 = createRadioButton('horseMatRadio2', 'gold', 'Gold', false)
			r2.onchange = =>
				@horseHead.changeMaterial('gold')
			r3 = createRadioButton('horseMatRadio3', 'chrome', 'Chrome', false)
			r3.onchange = =>
				@horseHead.changeMaterial('chrome')

			document.body.appendChild(container)

			# screenshot
			@captureCanvas = document.createElement('canvas')
			@captureCanvas.width = @videoWidth*2
			@captureCanvas.height = @videoHeight*2
			@captureCanvasContext = @captureCanvas.getContext('2d')
			@captureCanvasContext.translate(@videoWidth*2,0)
			@captureCanvasContext.scale(-1,1)


			btn = document.createElement('input')
			btn.type = 'button'
			# btn.value = 'screenshot'
			btn.id = 'shutter'
			document.body.appendChild(btn)
			btn.onclick = @screenshot



		render: =>

			requestAnimationFrame @render

			if(@ctrack.getCurrentPosition())

				@facePosition.update()

				n = 0.50

				op = @horseHead.position.clone()
				tp = op.add( @facePosition.position.sub(op).multiplyScalar(n) )
				@horseHead.position = tp

				trX = @horseHead.rotation.x + (@facePosition.rotation.x - @horseHead.rotation.x)*n
				trY = @horseHead.rotation.y + (@facePosition.rotation.y - @horseHead.rotation.y)*n
				trZ = @horseHead.rotation.z + (@facePosition.rotation.z - @horseHead.rotation.z)*n
				@horseHead.rotation.set( trX, trY, trZ )

				sc = @horseHead.scale.x + (@facePosition.scale - @horseHead.scale.x)*n
				@horseHead.scale.set( sc, sc, sc )

				m = @horseHead.mouth + (@facePosition.mouth - @horseHead.mouth)*0.6
				@horseHead.openMouth(m)

			@renderer.render(@scene, @camera)

			if @debug
				@stats.update()

				@overlayCC.clearRect(0,0,@videoWidth,@videoHeight)
				if @ctrack.getCurrentPosition()
					@ctrack.draw @overlay

		screenshot: =>
			evt = document.createEvent('MouseEvents')
			evt.initEvent('click', true, false, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null)
			a = document.createElement('a')
			# @captureCanvasContext.scale(2,2)
			# @captureCanvasContext.moveTo(-@videoWidth, -@videoHeight)
			@captureCanvasContext.drawImage(@inputVideo,0,0,@videoWidth*2,@videoHeight*2)
			@captureCanvasContext.drawImage(@renderer.domElement,0,0,@videoWidth*2,@videoHeight*2)

			# a.href = @renderer.domElement.toDataURL()
			a.href = @captureCanvas.toDataURL()
			a.download = "umazra-#{Date.now()}.png"
			a.dispatchEvent(evt)





