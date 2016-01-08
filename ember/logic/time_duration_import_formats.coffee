LabCompass.TimeDurationImportFormats = 
    [
      index: 0
      display: "HH:MM:SS (hours:minutes:seconds)"
      formatFunction: ((raw)->
        if raw == ""
          return {
            data: raw
            error: false
          }            

        try
          if raw.indexOf(".") != -1
            throw {"value contained decimals"}
          str = raw.trim()
          if isNaN(str.replace(':','').replace(':',''))
            throw {"value contained letters or extra colons"}
         
          c1 = str.indexOf(':')
          c2 = str.lastIndexOf(':')
         

          if c1 == 0
            throw {"no hours"}
          if c1 == -1
            throw {"no colon"}
          if c1 > 3
            throw {"too many hours"}
          if (c1 == c2)
            throw {"only one colon"}
          if c2 - c1 > 5
            throw {"too many minute chars"} 
          if c2 - c1 < 2
            throw {"too few minute chars"}
          if str.length - c2 > 7
            throw {"too many second chars"}
          if str.length - c2 < 2
            throw {"too few second chars"}
 
          hours = minutes = seconds = "0"
          hours = parseInt(str.substring(0, c1))
          minutes = parseInt(str.substring(c1+1, c2))
          seconds = parseInt(str.substring(c2+1))
          return_time = hours + ":" + minutes + ":" + seconds

          return {
            data: return_time
            error: false
          }

       
        catch error
          return {
            data: raw
            error: true
          }
      )
    ,
      index: 1
      display: "HH:MM (hours:minutes)"
      formatFunction: ((raw)->
        if raw == ""
          return {
            data: raw
            error: false
          }            

        try
          if raw.indexOf(".") != -1
            throw {"value contained decimals"}
          str = raw.trim()
          if isNaN(str.replace(':',''))
            throw {"value contained letters or extra colons"}
         
          c1 = str.indexOf(':')         

          if c1 == 0
            throw {"no hours"}
          if c1 == -1
            throw {"no colon"}  
          if c1 > 3
            throw {"too many hours"}
          if str.length - c1 > 5
            throw {"too many minute chars"}
          if str.length - c1 < 2
            throw {"too few minute chars"}
         
          hours = minutes = seconds = "0"
          hours = parseInt(str.substring(0, c1))
          minutes = parseInt(str.substring(c1+1))
          return_time = hours + ":" + minutes + ":" + seconds
          
          return {
            data: return_time
            error: false
          }

       
        catch error
          return {
            data: raw
            error: true
          }
      )
    ,
      index: 2
      display: "HH (hours)"
      formatFunction: ((raw)->
        if raw == ""
          return {
            data: raw
            error: false
          }            

        try
          if raw.indexOf(".") != -1
            throw {"value contained decimals"}
          str = raw.trim()
          beforeReplace = parseInt(str)
          #parse int here and check NaN to figure out if text is trailing
          if isNaN(str.replace(/hours/gi, "")) && isNaN(str.replace(/hrs/gi, "")) && isNaN(str.replace(/hour/gi, "")) && isNaN(str.replace(/hr/gi, ""))
            throw {"value contained non-numerical characters other than \"hour(s)\" or \"hr(s)\""}

          str = str.replace(/hours/gi, "")
          str = str.replace(/hrs/gi,   "")
          str = str.replace(/hour/gi, "")
          str = str.replace(/hr/gi,   "")
          str = str.trim()

          if str.length > 3
            throw {"too many hours"}

          if beforeReplace != parseInt(str)
            throw {"units can only trail the number"}

          hours = minutes = seconds = "0"
          hours = parseInt(str)
          return_time = hours + ":" + minutes + ":" + seconds
          
          return {
            data: return_time
            error: false
          }

       
        catch error
          return {
            data: raw
            error: true
          }
      )
    ,
      index: 3
      display: "MM:SS (minutes:seconds)"
      formatFunction: ((raw)->
        if raw == ""
          return {
            data: raw
            error: false
          }            

        try
          if raw.indexOf(".") != -1
            throw {"value contained decimals"}
          str = raw.trim()
          if isNaN(str.replace(':',''))
            throw {"value contained letters or extra colons"}
         
          c1 = str.indexOf(':')         

          if c1 == 0
            throw {"no minutes"}
          if c1 == -1
            throw {"no colon"}  
          if c1 > 4
            throw {"too many minutes"}
          if str.length - c1 > 7
            throw {"too many second chars"}
          if str.length - c1 < 2
            throw {"too few second chars"}
         
          hours = minutes = seconds = "0"
          minutes = parseInt(str.substring(0, c1))
          seconds = parseInt(str.substring(c1+1))
          return_time = hours + ":" + minutes + ":" + seconds
          
          return {
            data: return_time
            error: false
          }

       
        catch error
          return {
            data: raw
            error: true
          }
      )
    ,
      index: 4
      display: "MM (minutes)"
      formatFunction: ((raw)->
        if raw == ""
          return {
            data: raw
            error: false
          }            

        try
          if raw.indexOf(".") != -1
            throw {"value contained decimals"}
          str = raw.trim()
          beforeReplace = parseInt(str)
          #parse int here and check NaN to figure out if text is trailing
          if isNaN(str.replace(/minutes/gi, "")) && isNaN(str.replace(/mins/gi, "")) && isNaN(str.replace(/minute/gi, "")) && isNaN(str.replace(/min/gi, ""))
            throw {"value contained non-numerical characters other than \"minute(s)\" or \"min(s)\""}

          str = str.replace(/minutes/gi, "")
          str = str.replace(/mins/gi,   "")
          str = str.replace(/minute/gi, "")
          str = str.replace(/min/gi,   "")
          str = str.trim()
          
          if str.length > 4
            throw {"too many minutes"}
          if beforeReplace != parseInt(str)
            throw {"units can only trail the number"}

          hours = minutes = seconds = "0"
          minutes = parseInt(str)
          return_time = hours + ":" + minutes + ":" + seconds
          
          return {
            data: return_time
            error: false
          }

       
        catch error
          return {
            data: raw
            error: true
          }
      )
    ,
      index: 5
      display: "SS (seconds)"
      formatFunction: ((raw)->
        if raw == ""
          return {
            data: raw
            error: false
          }            

        try
          if raw.indexOf(".") != -1
            throw {"value contained decimals"}
          str = raw.trim()
          beforeReplace = parseInt(str)
          #parse int here and check NaN to figure out if text is trailing
          if isNaN(str.replace(/seconds/gi, "")) && isNaN(str.replace(/secs/gi, "")) && isNaN(str.replace(/second/gi, "")) && isNaN(str.replace(/sec/gi, ""))
            throw {"value contained non-numerical characters other than \"second(s)\" or \"sec(s)\""}

          str = str.replace(/seconds/gi, "")
          str = str.replace(/secs/gi,   "")
          str = str.replace(/second/gi, "")
          str = str.replace(/sec/gi,   "")
          str = str.trim()

          if str.length > 6
            throw {"too many seconds"}
          if beforeReplace != parseInt(str)
            throw {"units can only trail the number"}

          hours = minutes = seconds = "0"
          seconds = parseInt(str)
          return_time = hours + ":" + minutes + ":" + seconds
          return {
            data: return_time
            error: false
          }

       
        catch error
          return {
            data: raw
            error: true
          }
      )
    ,
      index: 6
      display: "Days (number-of-days)"
      formatFunction: ((raw)->
        if raw == ""
          return {
            data: raw
            error: false
          }            

        try
          if raw.indexOf(".") != -1
            throw {"value contained decimals"}
          str = raw.trim()
          beforeReplace = parseInt(str)
          #parse int here and check NaN to figure out if text is trailing
          if isNaN(str.replace(/days/gi, "")) && isNaN(str.replace(/day/gi, ""))
            throw {"value contained non-numerical characters other than \"day(s)\""}

          str = str.replace(/days/gi, "")
          str = str.replace(/day/gi,   "")
          str = str.trim()

          if beforeReplace != parseInt(str)
            throw {"units can only trail the number"}

          hours = minutes = seconds = "0"
          days = parseInt(str) #ASOUBDFIASBDPYIASBDASDPBNASPDBPAISBDIBASDIBASdb
          hours = days * 24 
          return_time = hours + ":" + minutes + ":" + seconds
                     
          return {
            data: return_time
            error: false
          }

       
        catch error
          return {
            data: raw
            error: true
          }
      )
    ]