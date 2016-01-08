LabCompass.DateImportFormats = 
    [
      index: 0
      display: "MM/DD/YYYY"
      formatFunction: ((raw)->
        if raw == ""
          return {
            data: raw
            error: false
          }       
        div = '/'
        try
          str = raw.replace(/\ /g, '').trim()
          if isNaN(str.replace(div,'').replace(div,''))
            throw {"value contained letters or extra slashes"}
         
          c1 = str.indexOf(div)
          c2 = str.lastIndexOf(div)
         

          if c1 == -1
            throw {"no slashes"}
          if (c1 == c2)
            throw {"only one slash"}

          if c1 == 0
            throw {"no Month chars"}
          if c1 > 2
          	throw {"too many Month chars"}

          month = str.substring(0, c1)

          if c2 - c1 > 3
            throw {"too many Day chars"} 
          if c2 - c1 < 2
            throw {"too few Day chars"}

          day = str.substring(c1+1, c2)

          if str.length - c2 > 5
            throw {"too many Year chars"}
          if str.length - c2 < 5
            throw {"too few Year chars"}
         
          year = str.substring(c2+1)       

          if month.length == 1
            month = '0' + month
          if day.length == 1
            day = '0' + day
          return_date = month + '/' + day + '/' + year
          
          return {
            data: return_date
            error: false
          }
       
        catch error
          #console.error error
          return {
            data: raw
            error: true
          }
      )
    ,
      index: 1
      display: "MM.DD.YYYY"
      formatFunction: ((raw)->
        if raw == ""
          return {
            data: raw
            error: false
          }      
          
        div = '.'
        try
          str = raw.replace(/\ /g, '').trim()
          if isNaN(str.replace(div,'').replace(div,'')) || str.replace(div,'').replace(div,'').indexOf(div) != -1
            throw {"value contained letters or extra periods"}
         
          c1 = str.indexOf(div)
          c2 = str.lastIndexOf(div)
         

          if c1 == -1
            throw {"no periods"}
          if (c1 == c2)
            throw {"only one period"}

          if c1 == 0
            throw {"no Month chars"}
          if c1 > 2
          	throw {"too many Month chars"}

          month = str.substring(0, c1)

          if c2 - c1 > 3
            throw {"too many Day chars"} 
          if c2 - c1 < 2
            throw {"too few Day chars"}

          day = str.substring(c1+1, c2)

          if str.length - c2 > 5
            throw {"too many Year chars"}
          if str.length - c2 < 5
            throw {"too few Year chars"}
         
          year = str.substring(c2+1)       


          if month.length == 1
            month = '0' + month
          if day.length == 1
            day = '0' + day
          return_date = month + '/' + day + '/' + year
          
          return {
            data: return_date
            error: false
          }
       
        catch error
          #console.error error
          return {
            data: raw
            error: true
          }
      )
    ,
      index: 2
      display: "MM-DD-YYYY"
      formatFunction: ((raw)->
        if raw == ""
          return {
            data: raw
            error: false
          }      
          
        div = '-'
        try
          str = raw.replace(/\ /g, '').trim()
          if isNaN(str.replace(div,'').replace(div,''))
            throw {"value contained letters or extra dashes"}
         
          c1 = str.indexOf(div)
          c2 = str.lastIndexOf(div)
         

          if c1 == -1
            throw {"no dashes"}
          if (c1 == c2)
            throw {"only one dashes"}

          if c1 == 0
            throw {"no Month chars"}
          if c1 > 2
          	throw {"too many Month chars"}

          month = str.substring(0, c1)

          if c2 - c1 > 3
            throw {"too many Day chars"} 
          if c2 - c1 < 2
            throw {"too few Day chars"}

          day = str.substring(c1+1, c2)

          if str.length - c2 > 5
            throw {"too many Year chars"}
          if str.length - c2 < 5
            throw {"too few Year chars"}
         
          year = str.substring(c2+1)       


          if month.length == 1
            month = '0' + month
          if day.length == 1
            day = '0' + day
          return_date = month + '/' + day + '/' + year
          
          return {
            data: return_date
            error: false
          }
       
        catch error
          #console.error error
          return {
            data: raw
            error: true
          }
      )
    ,







      index: 3
      display: "DD/MM/YYYY"
      formatFunction: ((raw)->
        if raw == ""
          return {
            data: raw
            error: false
          }      
          
        div = '/'
        try
          str = raw.replace(/\ /g, '').trim()
          if isNaN(str.replace(div,'').replace(div,''))
            throw {"value contained letters or extra slashes"}
         
          c1 = str.indexOf(div)
          c2 = str.lastIndexOf(div)
         

          if c1 == -1
            throw {"no slashes"}
          if (c1 == c2)
            throw {"only one slash"}

          if c1 == 0
            throw {"no Day chars"}
          if c1 > 2
          	throw {"too many Day chars"}

          day = str.substring(0, c1)

          if c2 - c1 > 3
            throw {"too many Month chars"} 
          if c2 - c1 < 2
            throw {"too few Month chars"}

          month = str.substring(c1+1, c2)

          if str.length - c2 > 5
            throw {"too many Year chars"}
          if str.length - c2 < 5
            throw {"too few Year chars"}
         
          year = str.substring(c2+1)       


          if month.length == 1
            month = '0' + month
          if day.length == 1
            day = '0' + day
          return_date = month + '/' + day + '/' + year
          
          return {
            data: return_date
            error: false
          }
       
        catch error
          #console.error error
          return {
            data: raw
            error: true
          }
      )
    ,
      index: 4
      display: "DD.MM.YYYY"
      formatFunction: ((raw)->
        if raw == ""
          return {
            data: raw
            error: false
          }      
          
        div = '.'
        try
          str = raw.replace(/\ /g, '').trim()
          if isNaN(str.replace(div,'').replace(div,'')) || str.replace(div,'').replace(div,'').indexOf(div) != -1
            throw {"value contained letters or extra periods"}
         
          c1 = str.indexOf(div)
          c2 = str.lastIndexOf(div)
         

          if c1 == -1
            throw {"no periods"}
          if (c1 == c2)
            throw {"only one period"}

          if c1 == 0
            throw {"no Day chars"}
          if c1 > 2
          	throw {"too many Day chars"}

          day = str.substring(0, c1)

          if c2 - c1 > 3
            throw {"too many Month chars"} 
          if c2 - c1 < 2
            throw {"too few Month chars"}

          month = str.substring(c1+1, c2)

          if str.length - c2 > 5
            throw {"too many Year chars"}
          if str.length - c2 < 5
            throw {"too few Year chars"}
         
          year = str.substring(c2+1)       


          if month.length == 1
            month = '0' + month
          if day.length == 1
            day = '0' + day
          return_date = month + '/' + day + '/' + year
          
          return {
            data: return_date
            error: false
          }
       
        catch error
          #console.error error
          return {
            data: raw
            error: true
          }
      )
    ,
      index: 5
      display: "DD-MM-YYYY"
      formatFunction: ((raw)->
        if raw == ""
          return {
            data: raw
            error: false
          }      
          
        div = '-'
        try
          str = raw.replace(/\ /g, '').trim()
          if isNaN(str.replace(div,'').replace(div,''))
            throw {"value contained letters or extra dashes"}
         
          c1 = str.indexOf(div)
          c2 = str.lastIndexOf(div)
         

          if c1 == -1
            throw {"no dashes"}
          if (c1 == c2)
            throw {"only one dashes"}

          if c1 == 0
            throw {"no Day chars"}
          if c1 > 2
          	throw {"too many Day chars"}

          day = str.substring(0, c1)

          if c2 - c1 > 3
            throw {"too many Month chars"} 
          if c2 - c1 < 2
            throw {"too few Month chars"}

          month = str.substring(c1+1, c2)

          if str.length - c2 > 5
            throw {"too many Year chars"}
          if str.length - c2 < 5
            throw {"too few Year chars"}
         
          year = str.substring(c2+1)       


          if month.length == 1
            month = '0' + month
          if day.length == 1
            day = '0' + day
          return_date = month + '/' + day + '/' + year
          
          return {
            data: return_date
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
      display: "YYYY/MM/DD"
      formatFunction: ((raw)->
        if raw == ""
          return {
            data: raw
            error: false
          }      
          
        div = '/'
        try
          str = raw.replace(/\ /g, '').trim()
          if isNaN(str.replace(div,'').replace(div,''))
            throw {"value contained letters or extra slashes"}
         
          c1 = str.indexOf(div)
          c2 = str.lastIndexOf(div)
         

          if c1 == -1
            throw {"no slashes"}
          if (c1 == c2)
            throw {"only one slash"}

          if c1 == 0
            throw {"no Year chars"}
          if c1 < 4
          	throw {'too few Year chars'}
          if c1 > 4
          	throw {"too many Year chars"}

          year = str.substring(0, c1)

          if c2 - c1 > 3
            throw {"too many Month chars"} 
          if c2 - c1 < 2
            throw {"too few Month chars"}

          month = str.substring(c1+1, c2)

          if str.length - c2 > 3
            throw {"too many Day chars"}
          if str.length - c2 < 2
            throw {"too few Day chars"}
         
          day = str.substring(c2+1)       


          if month.length == 1
            month = '0' + month
          if day.length == 1
            day = '0' + day
          return_date = month + '/' + day + '/' + year
          
          return {
            data: return_date
            error: false
          }
       
        catch error
          #console.error error
          return {
            data: raw
            error: true
          }
      )
    ,
      index: 7
      display: "YYYY.MM.DD"
      formatFunction: ((raw)->
        if raw == ""
          return {
            data: raw
            error: false
          }      
          
        div = '.'
        try
          str = raw.replace(/\ /g, '').trim()
          if isNaN(str.replace(div,'').replace(div,'')) || str.replace(div,'').replace(div,'').indexOf(div) != -1
            throw {"value contained letters or extra periods"}
         
          c1 = str.indexOf(div)
          c2 = str.lastIndexOf(div)
         

          if c1 == -1
            throw {"no periods"}
          if (c1 == c2)
            throw {"only one period"}

          if c1 == 0
            throw {"no Year chars"}
          if c1 < 4
          	throw {'too few Year chars'}
          if c1 > 4
          	throw {"too many Year chars"}

          year = str.substring(0, c1)

          if c2 - c1 > 3
            throw {"too many Month chars"} 
          if c2 - c1 < 2
            throw {"too few Month chars"}

          month = str.substring(c1+1, c2)

          if str.length - c2 > 3
            throw {"too many Day chars"}
          if str.length - c2 < 2
            throw {"too few Day chars"}
         
          day = str.substring(c2+1)       


          if month.length == 1
            month = '0' + month
          if day.length == 1
            day = '0' + day
          return_date = month + '/' + day + '/' + year
          
          return {
            data: return_date
            error: false
          }
       
        catch error
          #console.error error
          return {
            data: raw
            error: true
          }
      )
    ,
      index: 8
      display: "YYYY-MM-DD"
      formatFunction: ((raw)->
        if raw == ""
          return {
            data: raw
            error: false
          }      
          
        div = '-'
        try
          str = raw.replace(/\ /g, '').trim()
          if isNaN(str.replace(div,'').replace(div,''))
            throw {"value contained letters or extra dashes"}
         
          c1 = str.indexOf(div)
          c2 = str.lastIndexOf(div)
         

          if c1 == -1
            throw {"no dashes"}
          if (c1 == c2)
            throw {"only one dlash"}

          if c1 == 0
            throw {"no Year chars"}
          if c1 < 4
          	throw {'too few Year chars'}
          if c1 > 4
          	throw {"too many Year chars"}

          year = str.substring(0, c1)

          if c2 - c1 > 3
            throw {"too many Month chars"} 
          if c2 - c1 < 2
            throw {"too few Month chars"}

          month = str.substring(c1+1, c2)

          if str.length - c2 > 3
            throw {"too many Day chars"}
          if str.length - c2 < 2
            throw {"too few Day chars"}
         
          day = str.substring(c2+1)       


          if month.length == 1
            month = '0' + month
          if day.length == 1
            day = '0' + day
          return_date = month + '/' + day + '/' + year
          
          return {
            data: return_date
            error: false
          }
       
        catch error
          #console.error error
          return {
            data: raw
            error: true
          }
      )
    ,







      index: 9
      display: "YYYY/DD/MM"
      formatFunction: ((raw)->
        if raw == ""
          return {
            data: raw
            error: false
          }      
          
        div = '/'
        try
          str = raw.replace(/\ /g, '').trim()
          if isNaN(str.replace(div,'').replace(div,''))
            throw {"value contained letters or extra slashes"}
         
          c1 = str.indexOf(div)
          c2 = str.lastIndexOf(div)
         

          if c1 == -1
            throw {"no slashes"}
          if (c1 == c2)
            throw {"only one slash"}

          if c1 == 0
            throw {"no Year chars"}
          if c1 < 4
          	throw {'too few Year chars'}
          if c1 > 4
          	throw {"too many Year chars"}

          year = str.substring(0, c1)

          if c2 - c1 > 3
            throw {"too many Day chars"} 
          if c2 - c1 < 2
            throw {"too few Day chars"}

          day = str.substring(c1+1, c2)

          if str.length - c2 > 3
            throw {"too many Month chars"}
          if str.length - c2 < 2
            throw {"too few Month chars"}
         
          month = str.substring(c2+1)       


          if month.length == 1
            month = '0' + month
          if day.length == 1
            day = '0' + day
          return_date = month + '/' + day + '/' + year
          
          return {
            data: return_date
            error: false
          }
       
        catch error
          #console.error error
          return {
            data: raw
            error: true
          }
      )
    ,
      index: 10
      display: "YYYY.DD.MM"
      formatFunction: ((raw)->
        if raw == ""
          return {
            data: raw
            error: false
          }      
          
        div = '.'
        try
          str = raw.replace(/\ /g, '').trim()
          if isNaN(str.replace(div,'').replace(div,'')) || str.replace(div,'').replace(div,'').indexOf(div) != -1
            throw {"value contained letters or extra periods"}
         
          c1 = str.indexOf(div)
          c2 = str.lastIndexOf(div)
         

          if c1 == -1
            throw {"no periods"}
          if (c1 == c2)
            throw {"only one period"}

          if c1 == 0
            throw {"no Year chars"}
          if c1 < 4
          	throw {'too few Year chars'}
          if c1 > 4
          	throw {"too many Year chars"}

          year = str.substring(0, c1)

          if c2 - c1 > 3
            throw {"too many Day chars"} 
          if c2 - c1 < 2
            throw {"too few Day chars"}

          day = str.substring(c1+1, c2)

          if str.length - c2 > 3
            throw {"too many Month chars"}
          if str.length - c2 < 2
            throw {"too few Month chars"}
         
          month = str.substring(c2+1)      


          if month.length == 1
            month = '0' + month
          if day.length == 1
            day = '0' + day
          return_date = month + '/' + day + '/' + year
          
          return {
            data: return_date
            error: false
          }
       
        catch error
          #console.error error
          return {
            data: raw
            error: true
          }
      )
    ,
      index: 11
      display: "YYYY-DD-MM"
      formatFunction: ((raw)->
        if raw == ""
          return {
            data: raw
            error: false
          }      
          
        div = '-'
        try
          str = raw.replace(/\ /g, '').trim()
          if isNaN(str.replace(div,'').replace(div,''))
            throw {"value contained letters or extra dashes"}
         
          c1 = str.indexOf(div)
          c2 = str.lastIndexOf(div)
         

          if c1 == -1
            throw {"no dashes"}
          if (c1 == c2)
            throw {"only one dash"}

          if c1 == 0
            throw {"no Year chars"}
          if c1 < 4
          	throw {'too few Year chars'}
          if c1 > 4
          	throw {"too many Year chars"}

          year = str.substring(0, c1)

          if c2 - c1 > 3
            throw {"too many Day chars"} 
          if c2 - c1 < 2
            throw {"too few Day chars"}

          day = str.substring(c1+1, c2)

          if str.length - c2 > 3
            throw {"too many Month chars"}
          if str.length - c2 < 2
            throw {"too few Month chars"}
         
          month = str.substring(c2+1)     


          if month.length == 1
            month = '0' + month
          if day.length == 1
            day = '0' + day
          return_date = month + '/' + day + '/' + year
          
          return {
            data: return_date
            error: false
          }
       
        catch error
          #console.error error
          return {
            data: raw
            error: true
          }
      )
    ,







      index: 12
      display: "DD October, YYYY"
      formatFunction: ((raw)->
        if raw == ""
          return {
            data: raw
            error: false
          }      
          
        try
          str = raw.trim() 

          space = str.indexOf(' ')
          coma = str.lastIndexOf(',')

          day = str.substring(0, space).trim()
          if day.length < 1 
          	throw {"too few day chars"}
          if day.length > 2
          	throw {"too many day chars"}
          if isNaN(day)
          	throw {"non numeric day chars"}

          month_name = str.substring(space, coma).trim().toLowerCase()
          month = '00'
          switch month_name
            when 'january' then month = '01'
            when 'february' then month = '02'
            when 'march' then month = '03'
            when 'april' then month = '04'
            when 'may' then month = '05'
            when 'june' then month = '06'
            when 'july' then month = '07'
            when 'august' then month = '08'
            when 'september' then month = '09'
            when 'october' then month = '10'
            when 'november' then month = '11'
            when 'december' then month = '12'
            else throw {'month not recognized'}

          year = str.substring(coma+1).trim()
          if year.length != 4
          	throw {"too many/few year chars"}
          if isNaN(year)
          	throw {'non numeric year'}

          if day.length == 1
            day = '0' + day
          return_date = month + '/' + day + '/' + year
          
          return {
            data: return_date
            error: false
          }
       
        catch error
          #console.error error
          return {
            data: raw
            error: true
          }
      )
    ,
      index: 13
      display: "DD Oct, YYYY"
      formatFunction: ((raw)->
        if raw == ""
          return {
            data: raw
            error: false
          }      
          
        try
          str = raw.trim() 

          space = str.indexOf(' ')
          coma = str.lastIndexOf(',')

          day = str.substring(0, space).trim()
          if day.length < 1 
          	throw {"too few day chars"}
          if day.length > 2
          	throw {"too many day chars"}
          if isNaN(day)
          	throw {"non numeric day chars"}

          month_name = str.substring(space, coma).trim().toLowerCase()
          month = '00'
          switch month_name
            when 'jan' then month = '01'
            when 'feb' then month = '02'
            when 'mar' then month = '03'
            when 'apr' then month = '04'
            when 'may' then month = '05'
            when 'jun' then month = '06'
            when 'jul' then month = '07'
            when 'aug' then month = '08'
            when 'sep' then month = '09'
            when 'oct' then month = '10'
            when 'nov' then month = '11'
            when 'dec' then month = '12'
            else throw {'month not recognized'}

          year = str.substring(coma+1).trim()
          if year.length != 4
          	throw {"too many/few year chars"}
          if isNaN(year)
          	throw {'non numeric year'}

          if day.length == 1
            day = '0' + day
          return_date = month + '/' + day + '/' + year
          
          return {
            data: return_date
            error: false
          }
       
        catch error
          #console.error error
          return {
            data: raw
            error: true
          }
      )
    ,






      index: 14
      display: "October DD, YYYY"
      formatFunction: ((raw)->
        if raw == ""
          return {
            data: raw
            error: false
          }      
          
        try
          str = raw.trim() 

          space = str.indexOf(' ')
          coma = str.lastIndexOf(',')

          day = str.substring(space, coma).trim()
          if day.length < 1 
          	throw {"too few day chars"}
          if day.length > 2
          	throw {"too many day chars"}
          if isNaN(day)
          	throw {"non numeric day chars"}

          month_name = str.substring(0, space).trim().toLowerCase()
          month = '00'
          switch month_name
            when 'january' then month = '01'
            when 'february' then month = '02'
            when 'march' then month = '03'
            when 'april' then month = '04'
            when 'may' then month = '05'
            when 'june' then month = '06'
            when 'july' then month = '07'
            when 'august' then month = '08'
            when 'september' then month = '09'
            when 'october' then month = '10'
            when 'november' then month = '11'
            when 'december' then month = '12'
            else throw {'month not recognized'}

          year = str.substring(coma+1).trim()
          if year.length != 4
          	throw {"too many/few year chars"}
          if isNaN(year)
          	throw {'non numeric year'}

          if day.length == 1
            day = '0' + day
          return_date = month + '/' + day + '/' + year
          
          return {
            data: return_date
            error: false
          }
       
        catch error
          #console.error error
          return {
            data: raw
            error: true
          }
      )
    ,
      index: 15
      display: "Oct DD, YYYY"
      formatFunction: ((raw)->
        if raw == ""
          return {
            data: raw
            error: false
          }      
          
        try
          str = raw.trim() 

          space = str.indexOf(' ')
          coma = str.lastIndexOf(',')

          day = str.substring(space, coma).trim()
          if day.length < 1 
          	throw {"too few day chars"}
          if day.length > 2
          	throw {"too many day chars"}
          if isNaN(day)
          	throw {"non numeric day chars"}

          month_name = str.substring(0, space).trim().toLowerCase()
          month = '00'
          switch month_name
            when 'jan' then month = '01'
            when 'feb' then month = '02'
            when 'mar' then month = '03'
            when 'apr' then month = '04'
            when 'may' then month = '05'
            when 'jun' then month = '06'
            when 'jul' then month = '07'
            when 'aug' then month = '08'
            when 'sep' then month = '09'
            when 'oct' then month = '10'
            when 'nov' then month = '11'
            when 'dec' then month = '12'
            else throw {'month not recognized'}

          year = str.substring(coma+1).trim()
          if year.length != 4
          	throw {"too many/few year chars"}
          if isNaN(year)
          	throw {'non numeric year'}

          if day.length == 1
            day = '0' + day
          return_date = month + '/' + day + '/' + year
          
          return {
            data: return_date
            error: false
          }
       
        catch error
          #console.error error
          return {
            data: raw
            error: true
          }
      )
    ,





      index: 16
      display: "Monday, October DD, YYYY"
      formatFunction: ((raw)->
        if raw == ""
          return {
            data: raw
            error: false
          }      
          
        try
          str = raw.trim() 

          str = str.substring(str.indexOf(',')+1).trim()

          space = str.indexOf(' ')
          coma = str.lastIndexOf(',')

          day = str.substring(space, coma).trim()
          if day.length < 1 
          	throw {"too few day chars"}
          if day.length > 2
          	throw {"too many day chars"}
          if isNaN(day)
          	throw {"non numeric day chars"}

          month_name = str.substring(0, space).trim().toLowerCase()
          month = '00'
          switch month_name
            when 'january' then month = '01'
            when 'february' then month = '02'
            when 'march' then month = '03'
            when 'april' then month = '04'
            when 'may' then month = '05'
            when 'june' then month = '06'
            when 'july' then month = '07'
            when 'august' then month = '08'
            when 'september' then month = '09'
            when 'october' then month = '10'
            when 'november' then month = '11'
            when 'december' then month = '12'
            else throw {'month not recognized'}

          year = str.substring(coma+1).trim()
          if year.length != 4
          	throw {"too many/few year chars"}
          if isNaN(year)
          	throw {'non numeric year'}

          if day.length == 1
            day = '0' + day
          return_date = month + '/' + day + '/' + year
          
          return {
            data: return_date
            error: false
          }
       
        catch error
          #console.error error
          return {
            data: raw
            error: true
          }
      )
    ]