module ControllerHelpers
  def sign_in(user = User.new)
    if user.nil?
      controller.stubs(:current_user).returns(nil)
    else
      controller.stubs(:current_user).returns(user)
    end
  end
end
