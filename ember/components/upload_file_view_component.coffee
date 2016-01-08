#not used. Maybe not working
LabCompass.UploadFileViewComponent = Ember.TextField.extend
  name: null
  type: 'file'
  attributeBindings: ['name']
  change: (evt)=> 
    input = evt.target
    if (input.files && input.files[0])
      reader = new FileReader()
      reader.onload = (e) => 
        fileToUpload = reader.result
        @set('name', fileToUpload);
      
      reader.readAsDataURL(input.files[0]);
   