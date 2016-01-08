class PasswordResetSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :user_id
end
