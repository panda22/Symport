LabCompass.QueryParam = LD.Model.extend
	id: null
	formName: LD.attr "string", default: ""
	questionName: LD.attr "string", default: ""
	questionType : LD.attr "string", default: ""
	operator : LD.attr "string", default: ""
	value: LD.attr "string", default: ""
	sequenceNum: LD.attr "number"
	isLast: LD.attr "boolean", default: false
	isManyToOneInstance: LD.attr "boolean", default: false
	isManyToOneCount: LD.attr "boolean", default: false
	valueError: false
	isException: LD.attr "boolean", default: false
