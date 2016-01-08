class Auditor
  class << self
    def log_form_permissions(user, form_permissions)
      form_permissions.each do |p|
        AuditLogger.add(user, p)
      end
    end
  end
end