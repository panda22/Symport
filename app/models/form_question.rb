class FormQuestion < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :form_structure
  has_one :numerical_range_config, autosave: true
  has_one :text_config
  has_many :option_configs, autosave: true
  has_many :question_exceptions, autosave: true, dependent: :destroy

  validate do |question|
    seen = []
    blank_found = false
    blank_code_found = false
    question.option_configs.each do |option|
      if option.value == ""
        blank_found = true
      end
      if option.code == "" or option.code == nil
        blank_code_found = true
      end
      if seen.include? option.value
        errors[:option_configs] << ("Answer choice #{option.value} is a duplicate, please make sure all of the answer choices are different")
      end
      seen.push option.value
      if option.value && option.value.include?("|")
        errors[:option_configs] << ("Answer choices can not contain vertical bars (|). See answer choice " + option.value) 
      end
    end
    if blank_found
      errors[:option_configs] << ("Answer choices can not be empty.")
    end
    if blank_code_found
      errors[:option_configs] << ("Answer codes can not be empty.")
    end
    if question.question_type == "date"
      seen = {"date_month" => [], "date_day" => [], "date_year" => []}
      question.question_exceptions.each do |exc|
        if exc.exception_type != "date_month" or exc.exception_type != "date_day" or exc.exception_type != "date_year"
          exc.destroy!
          next
        end
        error_condition = seen[exc.exception_type].include?(exc.value) && exc.value != ""
        if error_condition
          errors[:exception] << ("You cannot have duplicate codes. Please change " + exc.value)
        end
        seen[exc.exception_type].push exc.value
      end
    else
      seen = []
      question.question_exceptions.each do |exc|
        if seen.include?(exc.value) && exc.value != ""
          errors[:exception] << ("You cannot have duplicate codes. Please change " + exc.value)
        end
        seen.push exc.value
      end
    end
    i = 0
    question.question_exceptions.each do |exc|
      if exc.deleted_at.nil?
        errors[:exceptions][i] = QuestionExceptionValidator.validate(exc)
        i = i + 1
      end
    end
  end



  has_many :form_question_conditions
  has_many :dependent_conditions, foreign_key: "depends_on_id", class_name: "FormQuestionCondition"

  has_many :form_answers

  validates :question_type, presence: true, inclusion: { in: QuestionTypes.types,
    message: "%{value} is not a valid question type" }

  validates :sequence_number, presence: {message: "must be specified"}
  validates :prompt, presence: {message: "Please enter a question prompt before saving", unless: lambda { question_type == "pagebreak" }}
  validates :variable_name, format: { with: /\A\w*\z/, message: "only allows letters, digits and _" }
  validates :display_number, presence: {message: "must be specified"}
  validates_with VariableNameValidator, fields: [:variable_name, :question_type]
  validates_with OptionConfigPresenceValidator
  validates_with RangeConfigValidator
end
