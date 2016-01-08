#******************************************************

# usage notes:

# purpose:
#   although intended for exporting csv data to user, this component can make a
#   call to the server without using ajax and will send authorization data in the
#   header. requires a bypass server side also, see export function in form_controller.rb

# params:
#   exportLink: target serverside url. begin with "/" to make local url call
#   disabled: will not work if set to true
#   additionalFields: array of names of properties sent as parameters in request
#   includePhi: default boolean parameter for request

# other notes:
#   additionalFields will only give the keys of the parameters in request. you cannot
#   pass key => value objects. the value must be the value of the controller or model
#   property with the same name as the key passed in from additionalFields

#******************************************************

LabCompass.ExportDataComponent = Ember.Component.extend

  tagName: "button"
  attributeBindings: ["disabled"]
  exportLink: ""
  additionalFields: []
  action: 'dataDownloaded'

  didInsertElement: ->
    @_super(arguments...)
    form = @$("form[name='export-form']")
    @get('additionalFields').forEach (binding) =>
      form.append("<input name='#{binding}' type='hidden' value=''></input>")


  getCookie: (cname) ->
    name = cname + '='
    ca = document.cookie.split(';')
    i = 0
    while i < ca.length
      c = ca[i]
      while c.charAt(0) == ' '
        c = c.substring(1)
      if c.indexOf(name) == 0
        return c.substring(name.length, c.length)
      i++
    ''

  checkCookie: ->
    if @getCookie("labcompass_download_file") == "loading"
      window.setTimeout(=>
        @checkCookie()
      , 1000)
    else
      $(".loadingContainer").css("visibility","hidden")
      document.cookie = "labcompass_download_file=loading"

  click: ->
    unless @get('disabled')
      document.cookie = "labcompass_download_file=loading"
      @checkCookie()
      form = @$("form[name='export-form']")
      @get('additionalFields').forEach (binding) =>
        convertedBinding = @get(binding)
        if Ember.typeOf(convertedBinding) == "instance"
          convertedBinding = convertedBinding.serialize()
        if Ember.typeOf(convertedBinding) == "object" or Ember.typeOf(convertedBinding) == "array"
          convertedBinding = JSON.stringify(convertedBinding)
        if form.find("input[name='#{binding}']").length == 0
          form.append("<input name='#{binding}' type='hidden' value=''></input>")
        form.find("input[name='#{binding}']").val(convertedBinding)
      form.find("input[name='X-LabCompass-Auth']").val @session.get('sessionToken')
      form.submit()
      $(".loadingContainer .table-header").text("Downloading")
      $(".loadingContainer").css("visibility","visible")
      form.find("input[name='X-LabCompass-Auth']").val ""
      @sendAction "action"

  csrfParam: (->
    $("meta[name=csrf-param]").attr("content")
  ).property()

  csrfValue: (->
    $("meta[name=csrf-token]").attr("content")
  ).property()

LabCompass.inject "component:export-data", "session", "session:main"
