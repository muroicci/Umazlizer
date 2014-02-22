THREE = require('THREE')
require('MTLLoader')
require('OBJMTLLoader')

module.exports = 
	class HorseHead extends THREE.Object3D

		constructor: (paramObj)->

			THREE.Object3D.call(this)

			@modelParams = paramObj

			@materialNormal = []
			@currentMaterial = 0

			loadedCount = 2

			loader = new THREE.OBJMTLLoader()
			loader.load( 'model/horse_head_r.obj', 'model/horse_head_r.mtl', (obj)=>
				@model = obj 
				if --loadedCount ==0 then @initModel()

				@model.traverse (child)=>
					if child instanceof THREE.Mesh 
						child.geometry.computeVertexNormals()
						# child.material = @materialChrome
						# child.material = @materialGold
						child.material.shading = THREE.SmoothShading
						child.material.needsUpdate = true
						@materialNormal.push(child.material)

						child.castShadow = true
						child.receiveShadow = true
			)

			loader2 = new THREE.OBJMTLLoader()
			loader2.load( 'model/horse_head_r_morph.obj', 'model/horse_head_r_morph.mtl', (obj)=>
				@morphTarget = obj
				if --loadedCount ==0 then @initModel()
			)

			@mouth = 0

			#environmentalMap
			path = 'model/environment/'
			urls = [
				path + 'posx.jpg'
				path + 'negx.jpg'
				path + 'posy.jpg'
				path + 'negy.jpg'
				path + 'posz.jpg'
				path + 'negz.jpg'
			]
			reflectionCube = THREE.ImageUtils.loadTextureCube(urls)

			#Gold
			@materialGold = new THREE.MeshPhongMaterial(
				color: 0xffa200
				ambient: 0x402900
				specular: 0xffd58c
				envMap: reflectionCube
				combine: THREE.MultiplyOperation
				shininess: 40
				reflectivity: 0.9
				# metal: true
			)

			# Chrome
			@materialChrome = new THREE.MeshPhongMaterial(
				color: 0x000000
				specular: 0xffffff
				envMap: reflectionCube
				combine: THREE.MixOperation
				reflectivity: 0.7
				shininess: 40
			)

		update: =>
			@model.position.set( @modelParams.x, @modelParams.y, @modelParams.z )
			@model.scale.set( @modelParams.scale, @modelParams.scale, @modelParams.scale )


		onLoad: =>
			return @

		initModel: =>
			@morphGeoms = []
			for obj, i in @model.children
				@model.children[i].dynamic = @morphTarget.children[i].dynamic = true
				@morphGeoms.push([@model.children[i].geometry, @model.children[i].geometry.clone(), @morphTarget.children[i].geometry.clone()])

			@model.rotation.z = Math.PI
			# @model.rotation.x = -7*Math.PI/180
			@add(@model)

			@model.position.set( @modelParams.x, @modelParams.y, @modelParams.z )
			@model.scale.set( @modelParams.scale, @modelParams.scale, @modelParams.scale )

			@openMouth(0)

			THREE.EventDispatcher.call(@)
			@.dispatchEvent({type:'ready'})


		openMouth: (@mouth) =>
			for mph, i in @morphGeoms
				g = mph[0]
				gA = mph[1]
				gB = mph[2]
				for v,j in gA.vertices
					vv = v.clone()
					vv.lerp(gB.vertices[j], 1-mouth)
					g.vertices[j].copy(vv)

				g.verticesNeedUpdate = true


		changeMaterial: (matName) =>
			switch matName
				when 'normal'
					@currentMaterial = 0
					mat = @materialNormal
				when 'gold'
					@currentMaterial = 1
					mat = @materialGold
				when 'chrome'
					@currentMaterial = 2
					mat = @materialChrome

			for child, i in @model.children
				if @currentMaterial is 0
					child.material = mat[i]
				else
					child.material = mat
				child.geometry.computeVertexNormals()
				child.material.needsUpdate = true




					
				
			



