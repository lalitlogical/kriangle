# frozen_string_literal: true

class Authentication < ApplicationRecord
  belongs_to :<%= @underscored_name %>
  validates :user_id, :token, :client_id, presence: true
end
