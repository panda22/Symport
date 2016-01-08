LabCompass.PhoneNumberImportFormats = 
    [
      index: 0
      display: "###-###-####"
      formatFunction: ((raw)->
        if raw == ""
          return {
            data: raw
            error: false
          }            

        try
          str = raw.trim()
          if str.indexOf('-') != 3
            throw {"bad area code length"}
          area = str.substring(0,3)
          if isNaN(area)
            throw {'bad area code content'}
          str = str.substring(4)

          if str.indexOf('-') != 3
            throw {"bad first three length"}
          first_three = str.substring(0,3)
          if isNaN(first_three)
            throw {'bad first three content'}
          str = str.substring(4)

          if(str.indexOf('-') != -1)
            return {'too many dashes'}
          last_four = str.substring(0, 4)
          if isNaN(last_four)
            throw {'bad last four content'}
          
          if (str.length == 4)
            return {
              data:  "(" + area + ")-" + first_three + "-" + last_four
              error: false
            }
          
          if (str[4] != ' ' && str[4] != 'x')
            throw {'bad last 4'}
          ext = str.substring(4).trim()
          
          if ext.indexOf(' ') != -1
            throw {'bad space in ext'}

          x = ext.indexOf('x')
          if x != 0
            throw {'bad x in extension'}

          if isNaN (ext.substring(x+1))
            throw {'bad extension content'}

          if ext == "x"
            ext = ""

          return {
            data: "(" + area + ")-" + first_three + "-" + last_four + ext
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
      display: "(###)-###-####"
      formatFunction: ((raw)->
        if raw == ""
          return {
            data: raw
            error: false
          }            

        try
          str = raw.trim()
          if str[0] != '(' || str[4] != ')'
            throw {'bad parenthesis'}
          str = str.replace("(", "").replace(")", "")
          if str.indexOf('-') != 3
            throw {"bad area code length"}
          area = str.substring(0,3)
          if isNaN(area)
            throw {'bad area code content'}
          str = str.substring(4)

          if str.indexOf('-') != 3
            throw {"bad first three length"}
          first_three = str.substring(0,3)
          if isNaN(first_three)
            throw {'bad first three content'}
          str = str.substring(4)

          if(str.indexOf('-') != -1)
            return {'too many dashes'}
          last_four = str.substring(0, 4)
          if isNaN(last_four)
            throw {'bad last four content'}
          
          if (str.length == 4)
            return {
              data: "(" + area + ")-" + first_three + "-" + last_four
              error: false
            }
          
          if (str[4] != ' ' && str[4] != 'x')
            throw {'bad last 4'}
          ext = str.substring(4).trim()
          
          if ext.indexOf(' ') != -1
            throw {'bad space in ext'}

          x = ext.indexOf('x')
          if x != 0
            throw {'bad x in extension'}

          if isNaN (ext.substring(x+1))
            throw {'bad extension content'}

          if ext == "x"
            ext = ""

          return {
            data: "(" + area + ")-" + first_three + "-" + last_four + ext
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
      display:  "##########"
      formatFunction: ((raw)->
        if raw == ""
          return {
            data: raw
            error: false
          }            

        try
          str = raw.trim()
          if isNaN(str.substring(0,10))
            throw {'bad chars in number'}
          if str.length < 10
            throw {'too short'}

          area = str.substring(0,3)
          str = str.substring(3)


          first_three = str.substring(0,3)
          str = str.substring(3)

          last_four = str.substring(0, 4)
          
          if (str.length == 4)
            return {
              data: "(" + area + ")-" + first_three + "-" + last_four
              error: false
            }
          
          if (str[4] != ' ' && str[4] != 'x')
            throw {'bad last 4'}
          ext = str.substring(4).trim()
          
          if ext.indexOf(' ') != -1
            throw {'bad space in ext'}

          x = ext.indexOf('x')
          if x != 0
            throw {'bad x in extension'}

          if isNaN (ext.substring(x+1))
            throw {'bad extension content'}

          if ext == "x"
            ext = ""

          return {
            data: "(" + area + ")-" + first_three + "-" + last_four + ext
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
      display:  "(###) ### ####"
      formatFunction: ((raw)->
        if raw == ""
          return {
            data: raw
            error: false
          }            

        try
          str = raw.trim()
          if str[0] != '(' || str[4] != ')'
            throw {'bad parenthesis'}
          str = str.replace("(", "").replace(")", "")
          
          if str.indexOf(' ') != 3
            throw {"bad area code length"}
          area = str.substring(0,3)
          if isNaN(area)
            throw {'bad area code content'}
          str = str.substring(4).trim()

          if str.indexOf(' ') != 3
            throw {"bad first three length"}
          first_three = str.substring(0,3)
          if isNaN(first_three)
            throw {'bad first three content'}
          str = str.substring(4).trim()

          last_four = str.substring(0, 4)
          if isNaN(last_four)
            throw {'bad last four content'}
          
          if (str.length == 4)
            return {
              data: "(" + area + ")-" + first_three + "-" + last_four
              error: false
            }

          if (str[4] != ' ' && str[4] != 'x')
            throw {'bad last 4'}
          ext = str.substring(4).trim()
          
          if ext.indexOf(' ') != -1
            throw {'bad space in ext'}

          x = ext.indexOf('x')
          if x != 0
            throw {'bad x in extension'}

          if isNaN (ext.substring(x+1))
            throw {'bad extension content'}

          if ext == "x"
            ext = ""

          return {
            data: "(" + area + ")-" + first_three + "-" + last_four + ext
            error: false
          }
         

        catch error
          return {
            data: raw
            error: true
          }
      )
    ]