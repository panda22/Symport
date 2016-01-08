$ ->
  $('<div id="labcompass-test-container">').appendTo $("body")

LabCompass.rootElement = "#labcompass-test-container"
LabCompass.setupForTesting()
LabCompass.injectTestHelpers()
emq.globalize()
setResolver LabCompass.__container__

