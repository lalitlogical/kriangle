class Add<%= controller_class_name %>CountTo<%= user_class.classify.pluralize %> < ActiveRecord::Migration[5.2]
  def change
    add_column :<%= user_class.pluralize %>, :<%= controller_class_name.downcase %>_count, :integer
  end
end
