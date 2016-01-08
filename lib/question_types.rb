class QuestionTypes
  def self.types
    [
      "text",
      "date",
      "zipcode",
      "checkbox",
      "radio",
      "dropdown",
      "email",
      "yesno",
      "timeofday",
      "timeduration",
      "numericalrange",
      "phonenumber",
      "header",
      "pagebreak"
    ]
  end

  def self.formatting_types
    [
      "header",
      "pagebreak"
    ]
  end
end
