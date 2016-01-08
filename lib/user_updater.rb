module UserUpdater
  module_function

  def update(user, user_info, do_audit=true)
    new_attributes = {
      first_name: user_info["firstName"],
      last_name: user_info["lastName"],
      affiliation: user_info["affiliation"],
      phone_number: user_info["phoneNumber"] || "none",
      field_of_study: user_info["fieldOfStudy"],
      last_viewed_project: user_info["lastViewedProject"],
      demo_progress: user_info["demoProgress"],
      last_viewed_page: user_info["lastViewedPage"],
      create: user_info["create"],
      import: user_info["import"],
      clean: user_info["clean"],
      format: user_info["format"],
      invite: user_info["invite"]
    }
    if user_info["password"].present? || user_info["passwordConfirmation"].present?
      if !user.authenticate user_info["currentPassword"]
        user.errors[:current_password] << "Current password is incorrect"
        raise ActiveRecord::RecordInvalid.new user
      end
      new_attributes[:password] = user_info["password"]
      new_attributes[:password_confirmation] = user_info["passwordConfirmation"] || ""
    end
    if do_audit
      AuditLogger.surround_edit user, user do
        user.update_attributes! new_attributes
      end
    else
      user.update_attributes! new_attributes
    end
    user
  end

end
