# frozen_string_literal: true

class Authentication < ApplicationRecord
  belongs_to :<%= underscored_user_class %>

  validates :user_id, :client_id, :token, presence: true
end
