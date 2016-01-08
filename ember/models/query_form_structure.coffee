LabCompass.QueryFormStructure = LD.Model.extend
	formID: LD.attr "string"
	formName: LD.attr "string"
	# TODO include shortName here and in query.emblem
	included: LD.attr "boolean"
	displayed: LD.attr "boolean"