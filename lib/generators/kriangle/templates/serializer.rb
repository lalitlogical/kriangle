class <%= @class_name %>Serializer < ActiveSerializer
  attributes <%= @column_names.present? ? @column_names.to_s.gsub(/\[|\]/, '') : ':id' %>

  # has_one :address
  # has_many :avatars

  # def custom_function
  #   some logic
  # end

end
