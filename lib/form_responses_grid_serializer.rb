class FormResponsesGridSerializer
  class << self
    def serialize(user, form_responses)
      form_responses.map { |response| FormResponseSerializer.serialize(user, response) }
    end
  end
end
