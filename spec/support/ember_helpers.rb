module EmberHelpers
  def trigger_transition
    old_url = current_url
    yield
    FirePoll.poll do
      current_url != old_url
    end
  end
end
