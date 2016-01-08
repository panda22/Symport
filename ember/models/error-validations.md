# Error reporting from the server API

They fall into a couple categories:

- Attribute Validations
- General errors, or errors not specific to particular fields
- Insufficient priveleges to perform requested action
- Missing valid session token (unauthorized)

## Validations

HTTP Response code: *422*

JSON Payload format:

    {
      "validations": {
        "name": ["Name cannot be blank"],
        "questions": {
          0: {
            "prompt": ["Can't be blank", "You're a bad person"],
          },
          4: {
            "prompt": ["There is already a question with this name"]
          }
        }
      }
    }

The client would see these errors and map them back into the errors object on LD.Model.

## General errors

HTTP Response code: *422*

JSON Payload:

    {
      "reason": "Couldn't do the thing for some reason"
    }

or

HTTP Response code: *404*

body: empty

## Missing/invalid session token

HTTP Response code: 401

body: empty

## Insufficient privileges

In this case the user has authenticated, but

HTTP Response code: 403

body: empty