# frozen_string_literal: true

class <%= @options[:class_name] || class_name %>Serializer < ActiveSerializer
  attributes :<%= @options[:attributes].join(', :') %>
  <%- unless skip_tips -%>
  # attributes :custom_function
  <%- end -%>

  <%- @options[:references].try(:each) do |parent_model| -%>
  belongs_to :<%= parent_model %>
  <%- end -%>
  <%- unless skip_tips -%>
  # association's example
  # belongs_to :user
  # has_one :address
  # has_many :avatars

  # def custom_function
  #   object.association(:association_model_name).loaded? ? object.association_model_name : {}
  # end

  # add your custom attributes here if required
  # def attributes(*args)
  #  hash = super
  #  # hash[:your_key] = object.some_method_call
  #  hash
  # end
  <%- end -%>
end
