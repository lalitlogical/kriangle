class Avatar < ApplicationRecord
  belongs_to :<%= underscored_user_class %>
  
  mount_uploader :image, AvatarUploader
end
