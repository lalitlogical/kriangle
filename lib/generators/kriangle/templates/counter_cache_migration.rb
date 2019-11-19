class Add<%= class_name.pluralize %>CountTo<%= @options[:belongs_to].classify.pluralize %> < ActiveRecord::Migration[5.2]
  def change
    add_column :<%= @options[:belongs_to].pluralize %>, :<%= class_name.pluralize.underscore %>_count, :integer, default: 0
  end
end
