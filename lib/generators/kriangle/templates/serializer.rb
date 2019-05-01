# frozen_string_literal: true

class <%= @options[:class_name] || class_name %>Serializer < ActiveSerializer
  attributes :<%= @options[:attributes].join(', :') %>
  # attributes :custom_function

  <%- @options[:belongs_to].try(:each) do |parent_model| -%>
  belongs_to :<%= parent_model %>
  <%- end -%>
  # association's example
  # belongs_to :user
  # has_one :address
  # has_many :avatars

  # def custom_function
  #   some logic goes here
  # end

  # add your custom attributes here if required
  # def attributes(*args)
  #  hash = super
  #  # hash[:your_key] = object.some_method_call
  #  hash
  # end
end
