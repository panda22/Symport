#= require jquery
#= require jquery_ujs
#= require foundation
#= require handlebars
#= require ember
#= require moment
#= require moment-timezone
#= require datatables
#= require dataTables.foundation
#= require pikaday
#= require PapaParse
#= require Slick/lib/jquery.event.drag-2.2
#= require Slick/lib/jquery.event.drop-2.2
#= require Slick/lib/jquery-ui.js

#= require Slick/slick.core
#= require Slick/slick.dataview
#= require Slick/slick.groupitemmetadataprovider
#= require Slick/slick.editors
#= require Slick/slick.grid.js
#= require Slick/plugins/slick.headermenu.js
#= require autosize-master
#= require fuzzymatch
#= require datatables-fixedcolumns
#= require_self
#= require qtip/jquery.qtip.js

#= require data/init
#= require_tree ./data
#= require lab_compass

# for more details see: http://emberjs.com/guides/application/
Ember.LOG_VERSION = false
window.LabCompass = Ember.Application.create()

$ -> $(document).foundation()
Foundation.global.namespace = ""