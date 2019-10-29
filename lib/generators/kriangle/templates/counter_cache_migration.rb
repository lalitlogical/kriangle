class Add<%= class_name.pluralize %>CountTo<%= user_class.classify.pluralize %> < ActiveRecord::Migration[5.2]
  def change
    add_column :<%= user_class.pluralize %>, :<%= class_name.pluralize.underscore %>_count, :integer, default: 0
  end
end
