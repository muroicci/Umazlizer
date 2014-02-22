
clm = require('clm')
THREE = require('THREE')

cross = (a, b) ->
	return a.x * b.y - a.y * b.x

module.exports =

	class FacePosition

		faceAspactRatio: 136.1802045416534 / 162.671599588226 #vlength / hlength
		faceBasicWidth: 145 * 0.5 # distance between point[1] and point[13]
		noseBasicLength: 12 * 0.5 # distance between point[62] and point 37

		constructor: (video, clmtrackr)->
			@video = video
			@videoWidth = video.width 
			@videoHeight = video.height 
			@tracker = clmtrackr
			@position = new THREE.Vector3()
			@rotation = new THREE.Euler(0, 0, Math.PI)

			@scale = 1
			@mouth = 0

		update: =>
			if(@tracker.getCurrentPosition())

				positions = @tracker.getCurrentPosition()

				# position
				z = -100
				angle = 45
				fov = 1 / Math.tan( angle*Math.PI/180 )
				size = if @videoWidth>@videoHeight then @videoWidth else @videoHeight
				size*=0.5
				px = -(positions[41][0] - @videoWidth/2) / z * fov * size *1.2
				py = (positions[41][1] - @videoHeight/2) / z * fov * size
				@position.set(px, py, z/2)

				# scale
				vl = new THREE.Vector2( positions[33][0]-positions[7][0], positions[33][1]-positions[7][1] )
				hl = new THREE.Vector2( positions[1][0]-positions[13][0], positions[1][1]-positions[13][1] )


				@scale = hl.length()/@faceBasicWidth

				#rotation

				#z
				uVec = new THREE.Vector2(1,0)
				vec = new THREE.Vector2( positions[33][0]-positions[7][0], positions[33][1]-positions[7][1] )
				cos = uVec.dot(vec) / (uVec.length()*vec.length())
				rotZ = Math.acos(cos) + Math.PI/2

				#y
				v1 = new THREE.Vector2( positions[33][0], positions[33][1] )
				v2 = new THREE.Vector2( positions[62][0], positions[62][1] )
				v3 = new THREE.Vector2( positions[37][0], positions[37][1] )
				l1 = v1.clone().sub(v2)
				l2 = v1.clone().sub(v3)
				cos = l1.dot(l2) / ( l1.length() * l2.length() )
				rotY = Math.acos(cos)*2.8
				if(cross(l1,l2)<0) then rotY*=-1

				#x
				nl = v2.distanceTo(v3)
				rotX = -(nl/@scale - @noseBasicLength)*Math.PI/180*5.6

				@rotation.set(rotX, rotY, rotZ)

				#mouth
				v1 = new THREE.Vector2(positions[60][0], positions[60][1] )
				v2 = new THREE.Vector2(positions[57][0], positions[57][1] )
				m = (v1.distanceTo(v2)/@scale)/5
				if m>1
					m = 1 
				else if m<0
				 	m = 0
				@mouth = m







