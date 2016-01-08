LabCompass.FormDataSortFuncs = Ember.Object.extend
  ascUnfilledFirst: (a, b) ->
    if a == null and b == null
      return 0
    if a == null
      return 1
    if b == null
      return -1
    if a["value"] == b["value"]
      return 0
    numA = Number(a["value"])
    numB = Number(b["value"])
    aCompareVal = a["value"]
    bCompareVal = b["value"]
    if !isNaN(numA) and !isNaN(numB)
      aCompareVal = numA
      bCompareVal = numB
    if aCompareVal < bCompareVal
      return 1
    else
      return -1
  descUnfilledFirst: (a, b) ->
    if a == null and b == null
      return 0
    if a == null
      return 1
    if b == null
      return -1
    if a["value"] == b["value"]
      return 0
    else if a["value"] == ""
      return 1
    else if b["value"] == ""
      return -1
    numA = Number(a["value"])
    numB = Number(b["value"])
    aCompareVal = a["value"]
    bCompareVal = b["value"]
    if !isNaN(numA) and !isNaN(numB)
      aCompareVal = numA
      bCompareVal = numB
    if aCompareVal < bCompareVal
      return -1
    else
      return 1
  ascUnfilledLast: (a, b) ->
    if a == null and b == null
      return 0
    if a == null
      return -1
    if b == null
      return 1
    if a["value"] == b["value"]
      return 0
    else if a["value"] == ""
      return -1
    else if b["value"] == ""
      return 1
    numA = Number(a["value"])
    numB = Number(b["value"])
    aCompareVal = a["value"]
    bCompareVal = b["value"]
    if !isNaN(numA) and !isNaN(numB)
      aCompareVal = numA
      bCompareVal = numB
    if aCompareVal < bCompareVal
      return 1
    else
      return -1
  descUnfilledLast: (a, b) ->
    if a == null and b == null
      return 0
    if a == null
      return -1
    if b == null
      return 1
    if a["value"] == b["value"]
      return 0
    numA = Number(a["value"])
    numB = Number(b["value"])
    aCompareVal = a["value"]
    bCompareVal = b["value"]
    if !isNaN(numA) and !isNaN(numB)
      aCompareVal = numA
      bCompareVal = numB
    if aCompareVal < bCompareVal
      return -1
    else
      return 1
  subjFirstCreated: (a, b) ->
    if a == null and b == null
      return 0
    if a == null
      return -1
    if b == null
      return 1
    unless "created" of a and "created" of b
      return 0
    if a["created"] == b["created"]
      return 0
    else if a["created"] < b["created"]
      return 1
    else
      return -1
  subjLastCreated: (a, b) ->
    if a == null and b == null
      return 0
    if a == null
      return -1
    if b == null
      return 1
    unless "created" of a and "created" of b
      return 0
    if a["created"] == b["created"]
      return 0
    else if a["created"] < b["created"]
      return -1
    else
      return 1
  subjFirstUpdated: (a, b) ->
    if a == null and b == null
      return 0
    if a == null
      return -1
    if b == null
      return 1
    unless "updated" of a and "updated" of b
      return 0
    if a["updated"] == b["updated"]
      return 0
    else if a["updated"] < b["updated"]
      return 1
    else
      return -1
  subjLastUpdated: (a, b) ->
    if a == null and b == null
      return 0
    if a == null
      return -1
    if b == null
      return 1
    unless "updated" of a and "updated" of b
      return 0
    if a["updated"] == b["updated"]
      return 0
    else if a["updated"] < b["updated"]
      return -1
    else
      return 1