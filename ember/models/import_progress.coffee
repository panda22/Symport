LabCompass.ImportProgress = LD.Model.extend
  id: null
  state: LD.attr "string"
  fileName: LD.attr "string"
  desiredStructures:  LD.hasMany "formStructure" 
  originalData: LD.attr
  responses: LD.attr
  subjectIdHeader: LD.attr "string"
  importMode: LD.attr "string", default: "all"
  mapping: LD.attr  #mapping[variable_name]=
  					#	{    header: 
					#		 formatIndex:      
  serialize: ->
  	structs = @get 'desiredStructures'
  	resps = @get 'responses'
  	mapping = @get 'mapping'

  	serialized = 
  		id: @get 'id'
  		state: @get 'state'
  		fileName: @get 'fileName'
  		desiredStructures: structs.map (struct) ->
  			struct: struct.get('id')
  		originalData: @get 'originalData'
  		responses: Object.keys(resps).map (prop) ->
  			formResponse = resps[prop].response
  			formResponseJSON =
  				subjectID: formResponse._data.subjectID
  				formStructureID: formResponse.get('formStructure').id
  				answers: formResponse.get('answers').content.map (answer) ->
  					id: answer.id
  					answer: answer.get('answer')
  					question: answer.get('question').id
  		subjectIdHeader: @get 'subjectIdHeader'
  		mapping: Object.keys(mapping).map (prop) ->
  			index = mapping[prop].formatIndex
  			if index == undefined
  				index = null
  			ret =
  				var: prop
  				header: mapping[prop].header
  				format_index: index


