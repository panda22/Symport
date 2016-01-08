#combo-box
#controls subjectID combo box selector dropdown
#deals with field focus, option showing and hiding, selection, and navigating
LabCompass.ComboBoxInstancesComponent = LabCompass.ComboBoxComponent.extend
  classNames: ["combo-box"]

LabCompass.inject "component:combo-box-instances", "logic", "combo-box:logic"
