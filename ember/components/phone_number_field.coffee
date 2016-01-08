#phone-number-field
#used by AnswerTypeSpecificUI for phone number type answers
LabCompass.PhoneNumberFieldComponent = Ember.Component.extend

  disabled: false
  areacode: ""
  phoneNumberFirstPart: ""
  phoneNumberSecondPart: ""
  extensionCode: ""


  setAnswerObserver: Ember.observer((->
    phoneNumber = @concatAllParts(@get('areacode'), @get("phoneNumberFirstPart"), @get("phoneNumberSecondPart"), @get("extensionCode"))
    if phoneNumber == "()--"
      @set 'value', ""
    else
      @set('value', phoneNumber)
  ), 'areacode', 'phoneNumberFirstPart', 'phoneNumberSecondPart', 'extensionCode')

  concatAllParts: (areacode, phoneNumberFirstPart, phoneNumberSecondPart, extension) ->
    phoneNum = "(#{areacode})-#{phoneNumberFirstPart}-#{phoneNumberSecondPart}"
    if extension
      phoneNum = "#{phoneNum}x#{extension}"
    phoneNum

  didInsertElement: ->
    @_super(arguments...)
    phoneNumber = @get('value')
    for property, value of @phoneNumberToParts(phoneNumber)
      @set(property, value)

  phoneNumberToParts: (phoneNumber) ->
    match = /^(\d{3}|\(\d{3}\))-(\d{3})-(\d{4})(?:x(\d+))?$/.exec phoneNumber

    if match
      areacode: match[1].replace(/\((\d{3})\)/,"$1")
      phoneNumberFirstPart: match[2]
      phoneNumberSecondPart: match[3]
      extensionCode: match[4]

