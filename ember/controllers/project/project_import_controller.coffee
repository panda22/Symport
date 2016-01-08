LabCompass.ProjectImportController = Ember.ObjectController.extend LabCompass.WithProject, 

  needs: ['application', 'project']
  onMobile: Ember.computed.alias 'controllers.application.onMobile'

  form_from_trans: null

  confirmedTransition: false
  restoreTransition: null
  handleTransition: (trans) ->
    if @get('state') == "file_upload_state" || @get('state') == "loadingState" || @get('confirmedTransition') || trans.targetName == "account.revalidate-session"
      @set 'confirmedTransition', false
      true
    else
      trans.abort()
      @set('restoreTransition', trans)
      @send "openDialog", "confirm_leave_import"
      false

  handleResize: (start)->
    if start
      try
        $(window).on 'resize', ->
          boxes = $(".advice1,.advice2,.advice3")
          $(".image-wrapper").height((boxes.width()/280.0) * 200.0)
    else
      $(window).off 'resize'

  resetProperties: ->
    @setState('file_upload_state')
    @set 'num_spreadsheet_rows', 0
    @set 'num_spreadsheet_cols', 0
    @set 'headerIndexMap', []
    @set 'headers_row', [] 
    @set 'values_rows', []
    @set 'existing_form', true
    @set 'form_selection', "*^*new form*^*"
    @set 'form_structure', null
    @set 'filtered_questions', []
    @set 'allowed_forms', []
    @set 'new_form_name', ""
    @set 'new_form_description', ""
    @set 'new_form_many_to_one', ""
    @set 'import_mode_selection', "all"
    @set 'single_column_id', true
    @set 'id_seperator', null
    @set 'subject_id_header', null
    @set 'secondary_id_header', null
    @set 'secondary_id_header_place', null
    @set 'question_mapping', null
    @set 'temp_map', []
    @set 'subjects_column', []
    @set 'resolved_duplicate_indexes', []
    @set 'show_error', false
    @set 'show_escape', true
    @set 'final_data_columns', []
    @set 'final_num_rows', 0


  loadFile: (->
    Ember.run.next =>
      name = @get 'fake_path_select'
      if Ember.isEmpty name
        return
      if name.substring(name.length-4) != ".csv"
        @send "openDialog", "import_csv_error"
        return
      file = document.getElementById('file-upload').files[0]
      if (file)
        reader = new FileReader()
        reader.onload = (e)=>
          str = e.target.result
          if str == "" 
            alert("Please make sure your CSV file is not empty")
          results = Papa.parse(str)
          if !Ember.isEmpty results.errors || Ember.isEmpty results.data
            alert("Please make sure your CSV file is well formatted")
          @set_file_name(name)
          @setupDisplayArrays(results.data)
        reader.readAsText(file)
  ).observes 'fake_path_select'


  ###############################
  #STATES
  ###############################
  show_error: false
  show_escape: true

  state: 'file_upload_state'

  file_upload_state: true
  file_preview_state: false
  select_existing_form_state: false
  new_form_state: false
  select_import_options_state: false
  mapping_state: false
  select_subject_id_state: false
  many_to_one_options_state: false
  missing_subject_state: false
  dup_subject_state: false
  mapping_confirmation_sub_state: false
  complete_state: false
  final_confirm_state: false
  not_mapping_confirmation_sub_state: true
  loadingState: false
  ###############################
  setState: (desiredState) ->
    if desiredState == @get("state")
      return
    states = ['file_upload_state',
              'file_preview_state',
              'select_existing_form_state',
              'new_form_state',
              'select_import_options_state',
              'mapping_state',
              'select_subject_id_state',
              'many_to_one_options_state',
              'missing_subject_state',
              'dup_subject_state',
              'complete_state',
              'final_confirm_state',
              'loadingState']
    for state in states
      @set state, false
    @set desiredState, true
    @set 'show_error', false
    Ember.run.next =>
      $(document).foundation()
    @set 'state', desiredState
  ###############################



  ###############################
  #RAW SPREADSHEET DATA
  ###############################
  num_spreadsheet_rows: 0
  num_spreadsheet_cols: 0
  headerIndexMap: []
  headers_row: [] 
  values_rows: []
  values_rows_preview: (->
    @get("values_rows").slice(0, 10)
  ).property "values_rows"
  fileName: ""
  shortFileName: ""
  ###############################
  set_file_name: (fake_name)-> 
    if fake_name == null || fake_name == ""
      return
    i = fake_name.indexOf "\\fakepath\\"
    name = fake_name.substring(i+10)
    @set 'new_form_name', name
    @set 'fileName', name
    if name.length > 13
      name = name.substring(0,13) + "...csv"
    @set 'shortFileName', name
  ###############################



  ###############################
  #FORM DATA
  ###############################
  existing_form: true
  form_selection: "*^*new form*^*"
  form_structure: null
  filtered_questions: []
  set_filtered_questions: ->
    form = @get 'form_structure'
    if Ember.isEmpty(form) || form == "*^*new form*^*" || !@get('existing_form')
      @set 'filtered_questions', []
      return
    
    questions = form.get('sortedQuestions')
    
    can_phi = form.get('userPermissions').get('viewPhiData')


    filtered_questions = []
    for question in questions
      unless question.get('type') == "header" || (!can_phi && question.get('personallyIdentifiable'))
        filtered_questions.push question
    
    @set 'filtered_questions', filtered_questions



  allowed_forms: []
  new_form_name: ""
  new_form_description: ""
  new_form_many_to_one: ""
  ###############################



  ###############################
  #MAPPING DATA
  ###############################  
  import_mode_selection: "all"
  single_column_id: true
  id_seperator: null
  subject_id_header: null
  secondary_id_header: null
  secondary_id_header_place: null
  set_secondary_id_header: (->
    head = @get 'secondary_id_header_place'
    if head
      @set 'secondary_id_header', head
  ).observes 'secondary_id_header_place'
  question_mapping: null
  temp_map: []
  ###############################
  subject_id_header_index: (->
    @get('headerIndexMap')[@get('subject_id_header')]
  ).property 'subject_id_header'
  secondary_id_header_index: (->
    @get('headerIndexMap')[@get('secondary_id_header')]
  ).property 'secondary_id_header'
  headers_without_subject: (->
    @get('headers_row').copy().removeObject(@get("subject_id_header"))
  ).property 'subject_id_header'
  headers_without_subject_or_secondary: (->
    @get('headers_without_subject').copy().removeObject(@get("secondary_id_header"))
  ).property 'secondary_id_header'
  ###############################

  ###############################
  #ERROR DATA
  ############################### 
  subjects_column: []
  before_missing: false
  current_missing: false
  after_missing: false
  missing_subject_index: -1
  remaining_missing_subjects: 0
  total_missing_subjects: 0
  has_next_missing: false
  has_prev_missing: false
  set_next_prev_missing: (->
    a = b = false
    missing_subject_index = @get 'missing_subject_index'
    @setNextMissingSubject(true)
    if @get('missing_subject_index') == -1
      @set 'has_next_missing', false
      a = true
    else
      @set 'has_next_missing', true
    @set 'missing_subject_index', missing_subject_index  
    @setNextMissingSubject(false)
    if @get('missing_subject_index') == -1
      @set 'has_prev_missing', false
      b = true
    else
      @set 'has_prev_missing', true
    @set 'missing_subject_index', missing_subject_index  
    if a && b
      @set 'more_missing', false
    else
      @set 'more_missing', true
  ).observes 'current_missing'  
  more_missing: false
  remaining_duplicate_subjects: 0
  total_duplicate_subjects: 0
  current_duplicates: null
  duplicate_buckets: []
  duplicate_bucket_index: -1
  has_next_dup: (->
    resolved_duplicate_indexes = @get 'resolved_duplicate_indexes'
    index = @get 'duplicate_bucket_index'
    duplicate_buckets = @get 'duplicate_buckets'
    while(index < duplicate_buckets.length-1)
      ++index
      if !resolved_duplicate_indexes.contains(index)
        return true
    return false
  ).property 'duplicate_bucket_index'
  has_prev_dup: (->
    resolved_duplicate_indexes = @get 'resolved_duplicate_indexes'
    index = @get 'duplicate_bucket_index'
    duplicate_buckets = @get 'duplicate_buckets'
    while(index > 0)
      --index
      if !resolved_duplicate_indexes.contains(index)
        return true
    return false
  ).property 'duplicate_bucket_index'
  resolved_duplicate_indexes: []
  more_duplicates: true

  ###############################

  setupDisplayArrays: (data)->
    i = 0
    v_rows = []
    for row in data  
      isEmpty = true
      for cell in row
        if !Ember.isEmpty(cell)
          isEmpty = false
      unless isEmpty
        if i == 0
          mapping = {}
          j = 0
          headers = []
          dup_heads = []
          for head in row
            if !Ember.isEmpty(head)
              head = head.trim().split(" ").join("_")
              incr = 1
              while dup_heads[head] == "x"
                new_head = head + "_" + incr
                incr = incr + 1
                if dup_heads[new_head] != "x"
                  head = new_head
              dup_heads[head] = "x"
              mapping[head] = j
              headers.push head
            j = j + 1
          @set 'num_spreadsheet_cols', j
          @set 'headerIndexMap', mapping
          @set 'headers_row', headers
        else
          v_rows[i-1] = row 
        i = i + 1
    @set 'values_rows', v_rows
    @set 'num_spreadsheet_rows', i
    @handleResize(false)
    @setState("file_preview_state")

  setupSelectingForms: ->
    allowed_forms = @get('project.structures.content')
    if allowed_forms.length == 0 
      @setupNewFormState()
    else
      @set('allowed_forms', allowed_forms)
      trans_form = @get('form_from_trans')
      if !Ember.isEmpty(trans_form)
        for form in allowed_forms
          if form.id == trans_form.id
            @set 'form_selection', form
            @set 'form_structure', form
            @set 'form_from_trans', null
      else
        @set('form_structure', "*^*new form*^*")
      @setState("select_existing_form_state")

  setupNewFormState: ->
    @setState("new_form_state")

  setupImportOptions: ->
    filtered_questions = @get 'filtered_questions'
    if Ember.isEmpty(filtered_questions) || filtered_questions.length == 0 ##if no questions, skip options and go straight to subject ID selection
      @setupMappingState()
    else
      @setState("select_import_options_state")

  setupMappingState: ->
    filtered_questions = @get 'filtered_questions'
    mode = @get "import_mode_selection"
    if mode == "columns" || Ember.isEmpty(filtered_questions) || filtered_questions.length == 0
      @setupSelectingSubject()
    else
      @setState("mapping_state")
      @set 'mapping_confirmation_sub_state', false
      @set 'not_mapping_confirmation_sub_state', true
      Ember.run.next =>
        @autoMapHeaders()

  autoMapHeaders: ->
    inputs = $("input.drop-down-input")
    normalHeads = @get("headers_row").copy()
    upperHeads = normalHeads.map (head)->
      head.replace(/\ /g, "_").toUpperCase()

    for input in inputs
      varName = ($(input)).parent().parent().parent().parent().children()[0].innerText.replace(/\ /g, "_").toUpperCase() 
      index = upperHeads.length - 1
      score_a = $.fuzzyMatch(upperHeads[0], varName).score
      score_a1 = $.fuzzyMatch(varName, upperHeads[0]).score
      real_score_a = Math.max(score_a, score_a1)
      bestIndex = 0
      while index > 0
        score_b = $.fuzzyMatch(upperHeads[index], varName).score
        score_b1 = $.fuzzyMatch(varName, upperHeads[index]).score
        real_score_b = Math.max(score_b, score_b1)
        if real_score_b > real_score_a
          real_score_a = real_score_b
          bestIndex = index
        --index

      if real_score_a > 0
        if normalHeads[bestIndex] != ""
          input.value = normalHeads[bestIndex]
          @styleDropdownColor(input, "#638cd3")
          normalHeads[bestIndex] = ""


  setupSelectingSubject: ->
    @setState("select_subject_id_state")

  setupManyToOneOptions: ->
    @setState("many_to_one_options_state")

  goBackToManyToOneOptions: ->
    @set 'secondary_id_header_place', @get('secondary_id_header')
    if @get('form_structure.isManyToOne')
      @setState("many_to_one_options_state")
    else
      @setState("select_subject_id_state")


  setupErrorStates: ->
    form = @get "form_structure"
    isManyToOne = form.get "isManyToOne"
    values_rows = @get "values_rows"
    subject_id_header_index = @get "subject_id_header_index"
    ids = []
    i = 0
    missing = 0
    for row in values_rows
      id = row[subject_id_header_index].trim()
      if !isManyToOne
        ids[i] = 
          id: id
          ignored: false
      else
        if @get('single_column_id')
          id_seperator = @get("id_seperator")
          ids[i] = 
            id: id.split(id_seperator)[0]
            sec_id: id.split(id_seperator)[1]
            ignored: false
        else
          secondary_id_header_index = @get("secondary_id_header_index")
          sec_id = row[secondary_id_header_index].trim()
          ids[i] = 
            id: id
            sec_id: sec_id
            ignored: false

      if ids[i].id == "" || (isManyToOne && ids[i].sec_id == "")
        missing++
      i++
    @set 'remaining_missing_subjects', missing
    @set 'total_missing_subjects', missing
    @set 'subjects_column', ids
    @set 'missing_subject_index' , -1
    @setNextMissingSubject()
    @setupMissingSubjectState(false)


  setNextMissingSubject: (next=true)->
    form = @get "form_structure"
    isManyToOne = form.get "isManyToOne"
    subjects = @get "subjects_column"
    i = @get 'missing_subject_index'
    while(1)
      if next
        ++i
      else
        --i
      if i < 0 || i >= subjects.length
        @set "missing_subject_index", -1
        return
      subject = subjects[i]
      unless subject.ignored
        if isManyToOne
          if Ember.isEmpty(subject.id) || Ember.isEmpty(subject.sec_id)
            @set "missing_subject_index", i
            return
        else
          if Ember.isEmpty(subject.id)
            @set "missing_subject_index", i
            return

  setupMissingSubjectState: (saving)->
    missing_subject_index = @get 'missing_subject_index'
    values_rows = @get 'values_rows'
    if missing_subject_index == -1
      @setupDuplicateSubjectState()
      return
    
    @set 'current_missing', @getDataRowsForResolution(missing_subject_index)

    if missing_subject_index > 0
      @set 'before_missing', @getDataRowsForResolution(missing_subject_index - 1)
    else
      @set 'before_missing', false

    if missing_subject_index < (values_rows.length - 1)
      @set 'after_missing', @getDataRowsForResolution(missing_subject_index + 1)
    else
      @set 'after_missing', false

    @setState 'missing_subject_state'
    if saving
      @flashBody()

    @setUpMissingFocusListener()
    Ember.run.next ->
      $("input")[0].focus()

  flashBody: ->
    Ember.run.next ->
      $(".body")[0].style.visibility = "hidden"
      Ember.run.later ->
        $(".body")[0].style.visibility = ""
      , 500

  setUpMissingFocusListener: ->
    Ember.run.next ->
      $("input").focusin ->
        $("#current-missing-row").addClass("selected")

      $("input").focusout ->
        $("#current-missing-row").removeClass("selected")

  setupDuplicateSubjectState: ->
    duplicate_buckets = []
    subjects = @get 'subjects_column'
    mto = @get "form_structure.isManyToOne"
    i = 0
    
    for subject in subjects
      unless subject.ignored
        if mto
          if Ember.isEmpty(duplicate_buckets[subject.id+'-*Q-*'+subject.sec_id])
            duplicate_buckets[subject.id+'-*Q-*'+subject.sec_id] = []
          duplicate_buckets[subject.id+'-*Q-*'+subject.sec_id].push @getDataRowsForResolution(i)
        else
          if Ember.isEmpty(duplicate_buckets["-*Q-*"+subject.id])
            duplicate_buckets["-*Q-*"+subject.id] = []
          duplicate_buckets["-*Q-*"+subject.id].push @getDataRowsForResolution(i)
      i++
    #need to save full dups for checking against?
    real_dups = []
    for subject in Object.keys(duplicate_buckets)
      if duplicate_buckets.hasOwnProperty(subject)
        bucket = duplicate_buckets[subject]
        if bucket.length > 1
          real_dups.push bucket

    if real_dups.length == 0
      @setupFinishImporting()
      return
    else if real_dups.length == 1
      @set 'more_duplicates', false
    else
      @set 'more_duplicates', true
    @set 'resolved_duplicate_indexes', []
    @set 'duplicate_buckets', real_dups
    @set 'duplicate_bucket_index', 0
    @set 'remaining_duplicate_subjects', real_dups.length
    @set 'total_duplicate_subjects', real_dups.length
    @set 'current_duplicates', real_dups[0]
    @setState('dup_subject_state')
    Ember.run.next ->
      $("input")[0].focus()

  getDataRowsForResolution: (index)->
    isManyToOne = @get 'form_structure.isManyToOne'
    single_column_id = @get 'single_column_id'
    values_rows = @get 'values_rows'
    subject_id_header_index = @get 'subject_id_header_index'
    secondary_id_header_index = @get 'secondary_id_header_index'
    subjects = @get 'subjects_column'
    i = 0
    rows_data = []
    for value in values_rows[index]
      unless i == subject_id_header_index || (i == secondary_id_header_index && isManyToOne && !single_column_id)
        rows_data.push value
      i++
    if isManyToOne  
      return {
        line: index+1
        ignored: subjects[index].ignored
        sub: subjects[index].id,
        sec: subjects[index].sec_id
        data: rows_data
      }
    else
      return {
        line: index+1
        ignored: subjects[index].ignored
        sub: subjects[index].id 
        data: rows_data
      }

  total_errors: 0
  final_num_rows: 0
  final_data_columns: []
  setupFinishImporting: ->
    @setupFinalQuestionColumns()
    @set 'total_errors', (@get('total_duplicate_subjects') + @get('total_missing_subjects'))
    @set 'show_escape', false
    subjects = @get 'subjects_column'
    i = 0
    if @get('import_mode_selection') == "rows"
      mto = @get 'form_structure.isManyToOne'
      @storage.findSubjectsByForm(@get('form_structure')).then (result)=>
        used_hash = {}
        for subject in result
          if !mto
            if subject.responses.length != 0
              used_hash[subject.subjectID] = "x"
          else
            if subject.responses.length != 0
              used_hash[subject.subjectID] = {}
            for response in subject.responses
              used_hash[subject.subjectID][response.secondaryID] = "x"

       
        for subject_row in subjects
          if !mto
            if used_hash[subject_row.id] == "x"
              subject_row.ignored = true
          else
            if used_hash[subject_row.id] && used_hash[subject_row.id][subject_row.sec_id] == "x"
              subject_row.ignored = true
          unless subject_row.ignored
            i++
        @set 'final_num_rows', i
        @setState "final_confirm_state"
    else
      for subject_row in subjects
        unless subject_row.ignored
          i++
      @set 'final_num_rows', i
      @setState "final_confirm_state"

  setupFinalQuestionColumns: ->
    data_columns = []
    unused_headers = []
    mto = @get('form_structure.isManyToOne')
    if mto && !@get('single_column_id')
      unused_headers = @get('headers_without_subject_or_secondary')
    else
      unused_headers = @get('headers_without_subject')
    mapping = @get('question_mapping')
    
    header_mapping = {}
    if mapping
      for q_id in Object.keys(mapping)
        if mapping.hasOwnProperty(q_id)
          q_info = mapping[q_id]
          if q_info.header
            unused_headers.removeObject(q_info.header)
            if q_info.other_option_header
              unused_headers.removeObject(q_info.other_option_header)
            data_columns.push
              question_id: q_id
              question_type: q_info.question_type
              header: q_info.header
              other_option_header: q_info.other_option_header 
              other_option_value: q_info.other_option_value
              answers: []

    unless @get('import_mode_selection') == 'rows'
      for header in unused_headers
        data_columns.push
          question_id: null
          question_type: null
          header: header
          other_option_header: null 
          other_option_value: null
          answers: []

    @set 'final_data_columns', data_columns

  reloadMapping: ->
    mapping = @get 'question_mapping'
    inputs = $("input.drop-down-input")
    old_info = mapping[inputs[0].parentElement.parentElement.id]
    for input in inputs
      new_info = mapping[input.parentElement.parentElement.id]
      if Ember.isEmpty(new_info)
        if Ember.isEmpty(old_info.other_option_header)
          $(input.parentElement.parentElement.parentElement.parentElement).addClass("ignored")
        else
          input.value = old_info.other_option_header
      else
        if Ember.isEmpty(new_info.header)
          $(input.parentElement.parentElement.parentElement.parentElement).addClass("ignored")
        else
          input.value = new_info.header
        old_info = new_info
        

  styleDropdownColor: (dropdown, color)->
    dropdown.style.borderColor = color
    dropdown.style.borderWidth = '2px'
    $(dropdown).on 'click', (event)=>
      event.target.style.borderColor = "#cccccc"
      event.target.style.borderWidth = "1px"

  setError: (msg)->
    if msg == ""
      @set 'show_error', false
    else
      @set 'show_error', true
      Ember.run.next ->
        $(".error-message").text(msg)
  
  actions:

    learnMore1: ->
      @send "openDialog", "learn_more_import_rows"
      
    learnMore2: ->
      @send "openDialog", "learn_more_import_columns"

    learnMore3: ->
      @send "openDialog", "learn_more_import_all"

    adviceHelp1: ->
      window.open("https://symport.freshdesk.com/support/solutions/articles/1963-preparing-your-data-for-import")

    adviceHelp2: ->
      window.open("https://symport.freshdesk.com/support/solutions/articles/2117-saving-as-a-csv")


    ignoreAllQuestions: ->
      button = $("#ignore-all-questions")
      rows = $(".mapping-row")
      if button.text() == "Ignore All"
        button.text("Undo All")
        button.attr('class', "undo")
        for row in rows
          $(row).addClass("ignored")
      else
        button.text("Ignore All")
        button.attr('class', "ignore")
        for row in rows
          $(row).removeClass("ignored")


    ignoreQuestion: (question)->
      input = $("#"+question.id)
      row = input.parent().parent()
      other_input = $("#"+question.get('variableName'))
      if row.hasClass("ignored")
        row.removeClass("ignored")
      else
        row.addClass("ignored")
        try
          other_input.parent().parent().addClass("ignored")

    ignoreOther: (question)->
      other_input = $("#"+question.get('variableName'))
      other_row = other_input.parent().parent()
      input = $("#"+question.id)
      row = input.parent().parent()
      if other_row.hasClass("ignored")
        other_row.removeClass("ignored")
        row.removeClass("ignored")
      else
        other_row.addClass("ignored")
        
    deleteMissingRow: (del)->
      @set 'current_missing.ignored', del

    deleteAllDuplicates: ->
      rows = @get 'current_duplicates'
      button = $("#delete-all-duplicates")
      if button.text() == "Delete All"
        button.text("Undo All").addClass('undo')
        for row in rows
          Ember.set(row, 'ignored', true)
      else
        button.text("Delete All").removeClass('undo')
        for row in rows
          Ember.set(row, 'ignored', false)
      return false

    deleteDuplicateRow: (row)->
      Ember.set(row, "ignored", true)
      return false

    undoDeleteDuplicateRow: (row)->
      Ember.set(row, "ignored", false)

    addNewQuestion: ->
      map = {}
      inputs = $('input.drop-down-input')
      for input in inputs
        input = $(input)
        if input.parent().parent().parent().parent().hasClass("ignored")
          map[input.parent().parent().attr('id')] = "\u200a"
        else
          map[input.parent().parent().attr('id')] = input.val()
      @set 'temp_map', map

      form = @get("form_structure")
      displayNumber = form.get('sortedQuestions').length+1
      lastQuestion = form.get('sortedQuestions')[form.get('sortedQuestions.length') - 1]
      if parseInt(lastQuestion.get('displayNumber')) != NaN
        displayNumber = parseInt(lastQuestion.get('displayNumber')) + 1
      newQuestion = @storage.createModel "formQuestion",
        questionNumber: 0
        sequenceNumber: form.get('sortedQuestions').length+1
        displayNumber: displayNumber
      @set 'adding_question_form', form
      @send "openDialog", "question", newQuestion, "questionImportingDialog"

    saveQuestion: (question) ->
      @storage.saveQuestion @get('adding_question_form'), question
      .then => 
        @set_filtered_questions()
        @send "loadingOff"
        @send "closeDialog"
        Ember.run.next =>
          map = @get 'temp_map'
          i = 0
          for input in $('input.drop-down-input')
            input = $(input)
            row = input.parent().parent().parent().parent()
            val = map[input.parent().parent().attr('id')]
            unless Ember.isEmpty val
              if val == "\u200a"
                row.addClass("ignored")
              else
                input.val(val)
      , ->
        Ember.run.next(=>
          question.set("hasErrors", true)
          $(".dialog button").each(->
            $(this).attr("disabled", false)
          )
        )

    backToData: ->
      @transitionToRoute "project.form-data"
    
    backToFile: ->
      @set 'fake_path_select', ""
      @handleResize(true)
      @setState 'file_upload_state'

    confirmPreview: ->
      @setupSelectingForms()

    backToPreview: ->
      @setState("file_preview_state")

    confirmFormSelection: ->
      form = @get("form_selection")
      if form == "*^*new form*^*"
        @setupNewFormState()
      if form == null
        alert("Please select a form")
        return
      if Ember.isEmpty form.id
        return
      @storage.loadFormStructure(form.id).then (structure) =>
        @set 'existing_form', true
        @set 'form_structure', structure
        @set_filtered_questions()
        @setupImportOptions()

    backToSelectForm: ->
      allowed_forms = @get('project.structures.content')
      if allowed_forms.length == 0 
        @send "backToPreview"
      else
        @setState("select_existing_form_state")

    confirmNewFormSelection: ->
      name = @get("new_form_name")
      if name == ""
        @setError("Please enter a form name")
        return
      for struct in @get("project.structures.content")
        if struct.get("name") == name
          @setError("Form name already exists")
          return
      new_form = @storage.createModel "formStructure"
      new_form.set("name", name)
      @set 'form_structure', new_form
      @set 'existing_form', false
      @set_filtered_questions()
      #new_form.set("description", @get("new_form_description"))
      @setupImportOptions()

    backToNewForm: ->
      form = @get "form_structure"
      if Ember.isEmpty form.id
        @setState("new_form_state")
      else
        @setState("select_existing_form_state")

    confirmImportOptions: ->
      @setupMappingState()

    backToOptions: ->
      filtered_questions = @get 'filtered_questions'
      if Ember.isEmpty(filtered_questions) || filtered_questions.length == 0 ##if no questions, skip options and go straight to subject ID selection
        @send "backToNewForm"
      else
        @setState "select_import_options_state"  
    
    checkMapping: ->
      headerIndexMap = @get 'headerIndexMap'
      filtered_questions = @get 'filtered_questions'
      question_mapping = {}
      all_good = true
      found_one = false
      for question in filtered_questions
        dropdown = $('#' + question.id )[0].children[0].children[0]
        if ($(dropdown)).parent().parent().parent().parent().hasClass("ignored")
          header = null
        else
          header = dropdown.value
          if Ember.isEmpty(header) || Ember.isEmpty(headerIndexMap[header])
            @styleDropdownColor(dropdown, 'red')
            all_good = false
          other_option_dropdown_parent = $('#' + question.get('variableName'))[0]
          other_option_header = ""
          if other_option_dropdown_parent
            if ($(other_option_dropdown_parent)).parent().parent().hasClass("ignored")
              other_option_header = null
            else
              other_option_dropdown = other_option_dropdown_parent.children[0].children[0]
              other_option_header = other_option_dropdown.value
              if Ember.isEmpty(other_option_header) || Ember.isEmpty(headerIndexMap[other_option_header])
                @styleDropdownColor(other_option_dropdown, 'red')
                all_good = false

        if all_good
          if header != null
            found_one = true
          if other_option_dropdown_parent
            question_mapping[question.id] =
              header: header
              question_type: question.get('type')
              other_option_header: other_option_header
              other_option_value: other_option_dropdown_parent.nextSibling.innerText
          else
            question_mapping[question.id] =
              header: header
              question_type: question.get('type')
              other_option_header: null
              other_option_value: null

      unless all_good
        @setError("Please select a valid option") 
        return
      if @get("import_mode_selection") == "rows" && !found_one
        @setError("Match columns to continue")
        return
      @setError("")
      @set 'question_mapping', question_mapping
      @set 'mapping_confirmation_sub_state', true
      @set 'not_mapping_confirmation_sub_state', false


    backToChooseMapping: ->
      @set 'mapping_confirmation_sub_state', false
      @set 'not_mapping_confirmation_sub_state', true
      return false

    acceptMapping: ->
      @setupSelectingSubject()

    backToMapping: ->
      filtered_questions = @get 'filtered_questions'
      mode = @get "import_mode_selection"
      if mode == "columns" || Ember.isEmpty(filtered_questions) || filtered_questions.length == 0
        @send "backToOptions"
      else
        Ember.run.next =>
          @reloadMapping()
        @setState "mapping_state"

    confirmSubjectID: ->
      subject = @get('subject_id_header')
      subject_index = @get('subject_id_header_index')
      if Ember.isEmpty(subject) || Ember.isEmpty(subject_index)
        @setError("Please enter only valid column headers")
        @styleDropdownColor($("input.drop-down-input")[0], 'red')
        return
      form = @get 'form_structure'
      if form.get('isManyToOne')
        @setupManyToOneOptions()
      else
        @setupErrorStates()
    
    backToSubject: ->
      @setState "select_subject_id_state"

    confirmManyToOneOptions: ->
      form = @get "form_structure"
      bail = false
      if Ember.isEmpty form.get('secondaryId')
        $("#empty-secondary").text("Please enter a name")
        bail = true
      else
        $("#empty-secondary").text("")
      
      single_column_id = @get 'single_column_id'
      if single_column_id
        sep = @get 'id_seperator'
        if Ember.isEmpty sep 
          $("#empty-seperator").text("Please enter a seperating character")
          bail = true
        else
          $("#empty-seperator").text("")
          sep = sep.trim()
          if sep == ""
            sep = " "
          @set 'id_seperator', sep
      else
        subject_id_header = @get 'subject_id_header'
        secondary_id_header = @get 'secondary_id_header'
        secondary_id_header_index = @get 'secondary_id_header_index'
        if Ember.isEmpty(secondary_id_header) || Ember.isEmpty(secondary_id_header_index)
          $("#bad-secondary").text("Please enter only valid column header")
          bail = true
        else if secondary_id_header == subject_id_header
          $("#bad-secondary").text("Subject ID and Secondary ID columns cannot be the same due to question two's answer")
          bail = true
        else
          $("#bad-secondary").text("")
      
      if bail
        @setError("Please fix the errors above")
        return
      @setError("")
      @setupErrorStates()

    nextMissingSubject: (next)->
      missing_subject_index = @get 'missing_subject_index'
      @setNextMissingSubject(next)
      if @get('missing_subject_index') == -1
        if next
          alert("that was ur last missing ID")
        else if confirm("Are you sure you wish to go back? You will lose changes to you Subject IDs.") 
          @goBackToManyToOneOptions()
        @set 'missing_subject_index', missing_subject_index  
      else
        @setupMissingSubjectState(false)
      @setError("")

    saveAndNextMissingSubject: ->
      missing_subject_index = @get 'missing_subject_index'
      current_missing = @get 'current_missing'
      mto = @get("form_structure.isManyToOne")
      sub = current_missing.sub
      ignored = current_missing.ignored
      if mto
        sec = current_missing.sec

      if !ignored && sub.trim() == "" || (mto && sec.trim() == "")
        if !mto
          @setError("Please enter a Subject ID")
        else
          @setError("Please enter a Subject ID, " + @get('form_structure.secondaryId') + " pair")
        return
       
      @setError("")
      @set 'remaining_missing_subjects', (@get('remaining_missing_subjects') - 1)
      subs = @get 'subjects_column' 
      subs[missing_subject_index].id = sub
      subs[missing_subject_index].ignored = ignored
      if mto
        subs[missing_subject_index].sec_id = sec
      @set 'subjects_column', subs   

      @setNextMissingSubject(true)
      if @get('missing_subject_index') == -1
        @set 'missing_subject_index', missing_subject_index
        @setNextMissingSubject(false)
        if @get('missing_subject_index') == -1
          @setupDuplicateSubjectState()
        else
          @setupMissingSubjectState(true)
      else
        @setupMissingSubjectState(true)


    nextDuplicateSubject: (next)->
      origin = i = @get 'duplicate_bucket_index'
      buckets = @get 'duplicate_buckets'
      resolved_duplicate_indexes = @get 'resolved_duplicate_indexes'
      first = true
      while(first || resolved_duplicate_indexes.contains(i))
        first = false
        if next
          ++i
        else
          --i
        if i >= buckets.length
          alert("last duplicate")
          return
        else
          if i < 0 
            if confirm("Are you sure you wish to go back? You will lose changes to you Subject IDs.") 
              @goBackToManyToOneOptions()
            return
      
      subjects = @get 'subjects_column'
      current_duplicates = buckets[origin]
      for row in current_duplicates
        Ember.set(row, 'sub', subjects[row.line-1].id)
        Ember.set(row, 'ignored', subjects[row.line-1].ignored)
        if @get('form_structure.isManyToOne')
          Ember.set(row, 'sec', subjects[row.line-1].sec_id)
      @setError("")
      $("#delete-all-duplicates").text("Delete All").removeClass("undo")
      @set 'duplicate_bucket_index', i
      @set 'current_duplicates', buckets[i]

    saveAndNextDuplicateSubject: ->
      subjects = @get 'subjects_column'
      current_duplicates = @get 'current_duplicates'
      mto = @get 'form_structure.isManyToOne'
      still_dups = []
      indexes_covered = []

      for dup_row in current_duplicates
        indexes_covered.push(dup_row.line-1)
        unless dup_row.ignored
          if dup_row.sub.trim() == "" || (mto && dup_row.sec.trim() == "")
            if !mto
              @setError("Please enter a Subject ID")
            else
              @setError("Please enter a Subject ID, " + @get('form_structure.secondaryId') + " pair")
            return
          for dup_row_2 in current_duplicates
            if dup_row_2.line != dup_row.line && !dup_row_2.ignored
              if mto 
                if dup_row.sub == dup_row_2.sub && dup_row.sec == dup_row_2.sec
                  @setError("Above Subject ID, " + @get("form_structure.secondaryId") + " pairs are still duplicates")
                  return
              else 
                if dup_row.sub == dup_row_2.sub
                  @setError("Above Subject IDs are still duplicates")
                  return
      
      for dup_row in current_duplicates
        i = -1
        unless dup_row.ignored
          for subject in subjects
            ++i
            if !indexes_covered.contains(i)
              if mto 
                if dup_row.sub == subject.id && dup_row.sec == subject.sec_id
                  still_dups.push(dup_row.sub+" - "+dup_row.sec)
              else 
                if dup_row.sub == subject.id
                  still_dups.push(dup_row.sub)

      if !Ember.isEmpty(still_dups)
        @setError(still_dups[0] + " already exists")
        return

      @setError("")
      for dup_row in current_duplicates
        subjects[dup_row.line-1].id = dup_row.sub
        subjects[dup_row.line-1].ignored = dup_row.ignored
        if mto
          subjects[dup_row.line-1].sec_id = dup_row.sec
      @set 'subjects_column', subjects
      duplicate_buckets = @get 'duplicate_buckets'
      duplicate_bucket_index = @get 'duplicate_bucket_index'

      resolved_duplicate_indexes = @get 'resolved_duplicate_indexes'
      resolved_duplicate_indexes.push(duplicate_bucket_index)
      @set "resolved_duplicate_indexes", resolved_duplicate_indexes
      if resolved_duplicate_indexes.length == duplicate_buckets.length
        @setupFinishImporting()
        return
      else if resolved_duplicate_indexes.length == duplicate_buckets.length-1
        @set 'more_duplicates', false
      
      Ember.run.next =>
        @flashBody()
      
      i = duplicate_bucket_index
      @set 'remaining_duplicate_subjects', (@get('remaining_duplicate_subjects') - 1)
      $("#delete-all-duplicates").text("Delete All").removeClass("undo")
      while(i < duplicate_buckets.length-1)
        ++i
        if !resolved_duplicate_indexes.contains(i)
          @set 'duplicate_bucket_index', i
          @set 'current_duplicates', duplicate_buckets[i]
          return
      i = duplicate_bucket_index
      while(i > 0)
        --i
        if !resolved_duplicate_indexes.contains(i)
          @set 'duplicate_bucket_index', i
          @set 'current_duplicates', duplicate_buckets[i]
          return
      
      alert("somethign went very wrong")
      return

    finalConfirm: ->
      data_columns = @get 'final_data_columns'
      subjects_column = []
      values_rows = @get('values_rows')
      subjects = @get('subjects_column')
      first_column = true
      suggested_delim = []
      delim = ''
      best = 0
      for column in data_columns
        if column.question_type == "checkbox"
          for char in ['|','/',':',';','-','.','&',',']
            i = 0
            sum = 0
            for subject_row in subjects
              raw_answer = values_rows[i++][@get('headerIndexMap')[column.header]].trim()
              if raw_answer.indexOf(char) != -1
                sum += 1
            if sum > best && sum > subjects.length / 3.0
              best = sum
              delim = char
        suggested_delim.push delim

      j = -1
      for column in data_columns
        j += 1
        header_index_into_values = @get('headerIndexMap')[column.header]
        other_header_index_into_values = @get('headerIndexMap')[column.other_option_header]
        other_option_value = column.other_option_value
        i = 0
        for subject_row in subjects
          data_row = values_rows[i++]
          if !subject_row.ignored
            raw_answer = data_row[header_index_into_values].trim()
            if column.question_type == "checkbox" || column.question_type == "radio"
              other_text = data_row[other_header_index_into_values]
              if column.question_type == "radio"
                if (Ember.isEmpty(raw_answer) || raw_answer == other_option_value) && !Ember.isEmpty(other_text)
                  formatted_answer = other_option_value + "\u200a" + other_text  #empty with other content
                else
                  formatted_answer = raw_answer
              else #checkbox
                delim = suggested_delim[j]
                if Ember.isEmpty(raw_answer)
                  parts = []
                else if Ember.isEmpty(delim)
                  parts = [raw_answer]
                else
                  parts = raw_answer.split(delim)
                if !Ember.isEmpty(other_text) 
                  if parts.contains(other_option_value)
                    parts[parts.indexOf(other_option_value)] = other_option_value + "\u200a" + other_text
                  else  
                    parts.push((other_option_value + "\u200a" + other_text))
                formatted_answer = parts.join('\u200c')
            else
              formatted_answer = raw_answer

            column.answers.push formatted_answer
            if first_column
              if @get('form_structure.isManyToOne')
                subjects_column.push
                  sub_id: subject_row.id
                  sec_id: subject_row.sec_id
              else
                subjects_column.push
                  sub_id: subject_row.id
        first_column = false;              


      form = @get('form_structure')
      f = 
        id: form.get('id')
        name: form.get('name')
        isManyToOne: form.get("isManyToOne")
        secondaryId: form.get('secondaryId')

      cols = data_columns.length
      rows = subjects_column.length
      time = Math.pow(rows,1.25) * cols * .00075
      @set 'time_to_upload', (parseInt(time/60) + 1)

      @storage.importFormDataByQuestions(@get('project.id'), f, subjects_column, data_columns, @get('fileName'), @get('import_mode_selection')).then =>
        @storage.loadProject(@get('project.id')).then (project)=>
          Ember.run.next =>
            formID = null
            formName = @get("form_structure.name")
            newForm = project.get("structures.content").findBy("name", formName)
            unless Ember.isEmpty(newForm)
              formID = newForm.id
            @storage.set('session.user.import', true)
            @transitionToRoute "project.form-data", project, {queryParams: {formID: formID}}

      @setState("loadingState")

    time_to_upload: 0

    confirmLeave: ->
      @send "closeDialog"
      trans = @get('restoreTransition')
      @set "confirmedTransition", true
      trans.retry()
