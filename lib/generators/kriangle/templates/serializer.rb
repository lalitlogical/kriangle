class <%= @class_name %>Serializer < ActiveSerializer
  attributes <%= @attributes ? @attributes : ':id' %>

  # has_one :address
  # has_many :avatars

  # def custom_function
  #   some logic
  # end

end
