module.exports = (grunt) ->

	grunt.initConfig 

		browserify:
			dist:
				src: ["src/main.coffee"] 
				dest: 'deploy/js/main.js'
				options:
					transform: ['coffeeify']
					shim:
						Detector:
							path: 'src/libs/Detector.js'
							exports: 'Detector'

						clm:
							path: 'src/libs/clmtrackr.min.js'
							exports: 'clm'
						pModel:
							path: 'src/libs/model_pca_20_svm.js'
							exports: 'pModel'
							
						jQuery:
							path: 'src/libs/jquery-2.0.3.min.js'
							exports: 'jQuery'

						TweenLite:
							path: 'src/libs/TweenLite.min.js'
							exports: 'TweenLite'
						CSSPlugin:
							path: 'src/libs/CSSPlugin.min.js'
							exports: ''
						EasePack:
							path: 'src/libs/EasePack.min.js'
							exports: ''

						THREE:
							path: 'src/libs/three.min.js'
							exports: 'THREE'
						OBJLoader:
							path: 'src/libs/OBJLoader.js'
							exports: ''
							depends: THREE: 'THREE'
						OBJMTLLoader:
							path: 'src/libs/OBJMTLLoader.js'
							exports: ''
							depends: THREE: 'THREE'
						MTLLoader:
							path: 'src/libs/MTLLoader.js'
							exports: ''
							depends: THREE: 'THREE'
						Stats:
							path: 'src/libs/Stats.js'
							exports: 'Stats'
						datgui:
							path: 'src/libs/dat.gui.js'
							exports: 'dat'


		coffee:
			compile:
				options:
					bare: true

		coffeelint:
			app: ['src/*.coffee']
			tests:
				options:
					'no_trailing_whitespace':
						'level': 'error'

		compass:
			dist:
				options:
					sassDir: 'src/sass'
					cssDir: 'deploy/css'
					imagesDir: 'src/images'
					generatedImagesDir: 'deploy/img'
					httpGeneratedImagesPath: '/img'


		watch: 
			html:
				files: ['deploy/*']

			scripts: 
				files: ['Gruntfile.coffee', 'src/*.coffee', 'src/sass/*.scss']
				tasks: ['browserify', 'coffee', 'compass']

			options:
				livereload: true

		connect:
			server:
				options:
					base: 'deploy'

		uglify:
			my_target:
				files:
					'deploy/js/main.min.js' : ['deploy/js/main.js']




	grunt.loadNpmTasks('grunt-browserify')
	grunt.loadNpmTasks('grunt-contrib-coffee')
	grunt.loadNpmTasks('grunt-coffeelint')
	grunt.loadNpmTasks('grunt-contrib-compass')
	grunt.loadNpmTasks('grunt-contrib-connect')
	grunt.loadNpmTasks('grunt-contrib-watch')
	grunt.loadNpmTasks('grunt-contrib-uglify')

	# grunt.registerTask('default', ['connect', 'browserify', 'coffee', 'uglify', 'compass', 'watch'])
	grunt.registerTask('default', ['connect', 'browserify', 'coffee', 'compass', 'watch'])

