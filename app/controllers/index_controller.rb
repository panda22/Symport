class IndexController < ApplicationController

  skip_before_filter :header_authenticate!, only: [:index]

  def index
  end

end
