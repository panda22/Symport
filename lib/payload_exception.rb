class PayloadException < Exception
  attr_reader :status, :error
  def initialize(status, error)
    @status = status
    @error = error
  end

  def self.validation_error(content)
    PayloadException.new(422, {validations: content})
  end

  def self.access_denied(message)
    PayloadException.new(403, {message: message})
  end
end
