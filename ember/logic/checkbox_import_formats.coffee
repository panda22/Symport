LabCompass.CheckboxImportFormats = 
    [
      index: 0
      display: ", (comma)"
      formatFunction: ((raw)->
        parts = raw.split(",")
        f = true
        val == ""
        for p in parts
          if f
            val = p.trim()
            f = false
          else
            val = val + "\u200c" + p.trim()  
        {
          data: val
          error: false
        }
      )
    ,
      index: 1
      display: "| (vertical bar)"
      formatFunction: ((raw)->
        parts = raw.split("|")
        f = true
        val == ""
        for p in parts
          if f
            val = p.trim()
            f = false
          else
            val = val + "\u200c" + p.trim()  
        {
          data: val
          error: false
        }
      )
    ,
      index: 2
      display: "/ (forward slash)"
      formatFunction: ((raw)->
        parts = raw.split("/")
        f = true
        val == ""
        for p in parts
          if f
            val = p.trim()
            f = false
          else
            val = val + "\u200c" + p.trim()  
        {
          data: val
          error: false
        }
      )
    ,
      index: 3
      display: ": (colon)"
      formatFunction: ((raw)->
        parts = raw.split(":")
        f = true
        val == ""
        for p in parts
          if f
            val = p.trim()
            f = false
          else
            val = val + "\u200c" + p.trim()  
        {
          data: val
          error: false
        }
      )
    ,
      index: 4
      display: "; (semi-colon)"
      formatFunction: ((raw)->
        parts = raw.split(";")
        f = true
        val == ""
        for p in parts
          if f
            val = p.trim()
            f = false
          else
            val = val + "\u200c" + p.trim()  
        {
          data: val
          error: false
        }
      )
    ,
      index: 5
      display: "- (dash)"
      formatFunction: ((raw)->
        parts = raw.split("-")
        f = true
        val == ""
        for p in parts
          if f
            val = p.trim()
            f = false
          else
            val = val + "\u200c" + p.trim()  
        {
          data: val
          error: false
        }
      )
    ,
      index: 6
      display: ". (period)"
      formatFunction: ((raw)->
        parts = raw.split(".")
        f = true
        val == ""
        for p in parts
          if f
            val = p.trim()
            f = false
          else
            val = val + "\u200c" + p.trim()  
        {
          data: val
          error: false
        }
      )
    ,
      index: 7
      display: "& (ampersand)"
      formatFunction: ((raw)->
        parts = raw.split("&")
        f = true
        val == ""
        for p in parts
          if f
            val = p.trim()
            f = false
          else
            val = val + "\u200c" + p.trim()  
        {
          data: val
          error: false
        }
      )  
    ]