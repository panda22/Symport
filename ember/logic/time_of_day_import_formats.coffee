LabCompass.TimeOfDayImportFormats = 
    [
      index: 0
      display: "HH:MM [AM/PM]"
      formatFunction: ((raw)->
        if raw == ""
          return {
            data: raw
            error: false
          }            

        am_pm = ''
        try
          str = raw.toLowerCase().trim()
          if isNaN(str.replace(':','').replace('am', "")) && isNaN(str.replace(':','').replace('pm', ""))
            throw {"value contained letters or extra colons"}
         
          c1 = str.indexOf(':')

          if str.toLowerCase().indexOf('am') != -1
            if str.toLowerCase().indexOf('am') - c1 < 3
              throw {"am appeared before complete time value"} 
            am_pm = 'am'
            str = str.replace(/am/gi, "")
          else if str.toLowerCase().indexOf('pm') != -1
            if str.toLowerCase().indexOf('pm') - c1 < 3
              throw {"pm appeared before complete time value"} 
            am_pm = 'pm'
            str = str.replace(/pm/gi, "")
          else
            throw {"no am or pm found"}
          str = str.trim()

          if c1 > 2
            throw {"too many hours"}
          if c1 == 0
            throw {"no hours"}
          if c1 == -1
            throw {"no colon"}  
          if str.length - c1 != 3
            throw {"wrong number of minute chars"}
         
          hours = str.substring(0, c1)
          minutes = str.substring(c1+1, c1+3)

          h = parseInt(hours)
          if h < 1 || h > 12
            throw {'hours must be between 1 and 12'}

          return_time = hours + ":" + minutes + " " + am_pm.toUpperCase()

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
      display: "HH [AM/PM]"
      formatFunction: ((raw)->
        if raw == ""
          return {
            data: raw
            error: false
          }            

        am_pm = ''
        try
          str = raw.toLowerCase().trim()
          beforeParse = parseInt(str)
          if isNaN(str.replace('am', "")) && isNaN(str.replace('pm', ""))
            throw {"value contained extra non numeric characters"}
         

          if str.indexOf('am') != -1
            am_pm = 'am'
            str = str.replace('am', "")
          else if str.indexOf('pm') != -1
            am_pm = 'pm'
            str = str.replace('pm', "")
          else
            throw {"no am or pm found"}
          str = str.trim()

          if str.length == 0
            throw {'too few hours'}

          if beforeParse != parseInt(str)
            throw {'am/pm messing up parsing'}

          if str.length > 2 
            throw {'too many hours'}

          h = parseInt(str)
          if h < 1 || h > 12
            throw {'hours must be between 1 and 12'}

          return_time = str + ":" + '00' + " " + am_pm.toUpperCase()

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
      display: "HH:MM (24 hour time)"
      formatFunction: ((raw)->
        if raw == ""
          return {
            data: raw
            error: false
          }            

        try
          str = raw.trim()
          if isNaN(str.replace(':',''))
            throw {"value contained letters or extra colons"}
         
          c1 = str.indexOf(':')

          if c1 > 2
            throw {"too many hours"}
          if c1 == 0
            throw {"no hours"}
          if c1 == -1
            throw {"no colon"}  
          if str.length - c1 != 3
            throw {"wrong number of minute chars"}
         
          hours = parseInt(str.substring(0, c1))
          minutes = str.substring(c1+1, c1+3)

          am_pm = 'am'
          if hours == 0
            hours = 12
          else if hours >= 12 
            am_pm = 'pm'
            if hours > 24 
              throw {'hours must be within 0 and 24'}
            else if hours == 24
              am_pm = 'am'
              if minutes != '00'
                throw {'use 00:MM not 24:MM'}
            if hours != 12
              hours = hours - 12


          return_time = hours + ":" + minutes + " " + am_pm.toUpperCase()

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
      display: "HH (24 hour time)"
      formatFunction: ((raw)->
        if raw == ""
          return {
            data: raw
            error: false
          }            

        try
          str = raw.trim()

          if isNaN(str)
            throw {"value contained extra non numeric characters"}
         

          if str.length == 0
            throw {'too few hours'}

          if str.length > 2 
            throw {'too many hours'}

          hours = parseInt(str)

          am_pm = 'am'
          if hours == 0
            hours = 12
          else if hours >= 12 
            am_pm = 'pm'
            if hours > 24 
              throw {'hours must be within 0 and 24'}
            else if hours == 24
              am_pm = 'am'
            if hours != 12
              hours = hours - 12


          return_time = hours + ":" + '00' + " " + am_pm.toUpperCase()

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
      display: "Pull time from DD/MM/YY HH:MM [am/pm]"
      formatFunction: ((raw)->
        if raw == ""
          return {
            data: raw
            error: false
          }            

        try
          full_str = raw.trim()
          slash = full_str.lastIndexOf('/')
          if full_str[slash+3] != ' '
            throw "improper year format or no space between year and time"
          str = full_str.substring(slash+3)
          
          str = str.toLowerCase().trim()

          if isNaN(str.replace(':','').replace('am', "")) && isNaN(str.replace(':','').replace('pm', ""))
            throw {"value contained letters or extra colons"}
         
          c1 = str.indexOf(':')

          if str.toLowerCase().indexOf('am') != -1
            if str.toLowerCase().indexOf('am') - c1 < 3
              throw {"am appeared before complete time value"} 
            am_pm = 'am'
            str = str.replace(/am/gi, "")
          else if str.toLowerCase().indexOf('pm') != -1
            if str.toLowerCase().indexOf('pm') - c1 < 3
              throw {"pm appeared before complete time value"} 
            am_pm = 'pm'
            str = str.replace(/pm/gi, "")
          else
            throw {"no am or pm found"}
          str = str.trim()

          if c1 > 2
            throw {"too many hours"}
          if c1 == 0
            throw {"no hours"}
          if c1 == -1
            throw {"no colon"}  
          if str.length - c1 != 3
            throw {"wrong number of minute chars"}
         
          hours = str.substring(0, c1)
          minutes = str.substring(c1+1, c1+3)

          h = parseInt(hours)
          if h < 1 || h > 12
            throw {'hours must be between 1 and 12'}

          return_time = hours + ":" + minutes + " " + am_pm.toUpperCase()

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
      display: "Pull time from DD/MM/YYYY HH:MM [am/pm]"
      formatFunction: ((raw)->
        if raw == ""
          return {
            data: raw
            error: false
          }            

        try
          full_str = raw.trim()
          slash = full_str.lastIndexOf('/')
          if full_str[slash+5] != ' '
            throw "improper year format or no space between year and time"
          str = full_str.substring(slash+5)
          str = str.toLowerCase().trim()

          if isNaN(str.replace(':','').replace('am', "")) && isNaN(str.replace(':','').replace('pm', ""))
            throw {"value contained letters or extra colons"}
         
          c1 = str.indexOf(':')

          if str.toLowerCase().indexOf('am') != -1
            if str.toLowerCase().indexOf('am') - c1 < 3
              throw {"am appeared before complete time value"} 
            am_pm = 'am'
            str = str.replace(/am/gi, "")
          else if str.toLowerCase().indexOf('pm') != -1
            if str.toLowerCase().indexOf('pm') - c1 < 3
              throw {"pm appeared before complete time value"} 
            am_pm = 'pm'
            str = str.replace(/pm/gi, "")
          else
            throw {"no am or pm found"}
          str = str.trim()

          if c1 > 2
            throw {"too many hours"}
          if c1 == 0
            throw {"no hours"}
          if c1 == -1
            throw {"no colon"}  
          if str.length - c1 != 3
            throw {"wrong number of minute chars"}
         
          hours = str.substring(0, c1)
          minutes = str.substring(c1+1, c1+3)

          h = parseInt(hours)
          if h < 1 || h > 12
            throw {'hours must be between 1 and 12'}

          return_time = hours + ":" + minutes + " " + am_pm.toUpperCase()

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
      display: "Pull time from DD/MM/YY HH:MM (24 hr)"
      formatFunction: ((raw)->
        if raw == ""
          return {
            data: raw
            error: false
          }            

        try
          full_str = raw.trim()
          slash = full_str.lastIndexOf('/')
          if full_str[slash+3] != ' '
            throw "improper year format or no space between year and time"
          str = full_str.substring(slash+3)
          str = str.trim()
          
          if isNaN(str.replace(':',''))
            throw {"value contained letters or extra colons"}
         
          c1 = str.indexOf(':')

          if c1 > 2
            throw {"too many hours"}
          if c1 == 0
            throw {"no hours"}
          if c1 == -1
            throw {"no colon"}  
          if str.length - c1 != 3
            throw {"wrong number of minute chars"}
         
          hours = parseInt(str.substring(0, c1))
          minutes = str.substring(c1+1, c1+3)

          am_pm = 'am'
          if hours == 0
            hours = 12
          else if hours >= 12 
            am_pm = 'pm'
            if hours > 24 
              throw {'hours must be within 0 and 24'}
            else if hours == 24
              am_pm = 'am'
              if minutes != '00'
                throw {'use 00:MM not 24:MM'}
            if hours != 12
              hours = hours - 12
            

          return_time = hours + ":" + minutes + " " + am_pm.toUpperCase()

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
      index: 7
      display: "Pull time from DD/MM/YYYY HH:MM (24 hr)"
      formatFunction: ((raw)->
        if raw == ""
          return {
            data: raw
            error: false
          }            

        try
          full_str = raw.trim()
          slash = full_str.lastIndexOf('/')
          if full_str[slash+5] != ' '
            throw "improper year format or no space between year and time"
          str = full_str.substring(slash+5)
          
          str = str.trim()
          
          if isNaN(str.replace(':',''))
            throw {"value contained letters or extra colons"}
         
          c1 = str.indexOf(':')

          if c1 > 2
            throw {"too many hours"}
          if c1 == 0
            throw {"no hours"}
          if c1 == -1
            throw {"no colon"}  
          if str.length - c1 != 3
            throw {"wrong number of minute chars"}
         
          hours = parseInt(str.substring(0, c1))
          minutes = str.substring(c1+1, c1+3)

          am_pm = 'am'
          if hours == 0
            hours = 12
          else if hours >= 12 
            am_pm = 'pm'
            if hours > 24 
              throw {'hours must be within 0 and 24'}
            else if hours == 24
              am_pm = 'am'
              if minutes != '00'
                throw {'use 00:MM not 24:MM'}
            if hours != 12
              hours = hours - 12
            

          return_time = hours + ":" + minutes + " " + am_pm.toUpperCase()

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