class Authentication < ApplicationRecord
  belongs_to :<%= @underscored_name %>
end
