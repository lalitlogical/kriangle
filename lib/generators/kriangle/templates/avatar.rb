class Avatar < ApplicationRecord
  belongs_to :<%= @underscored_name %>
  mount_uploader :image, AvatarUploader
end
