class Create<%= controller_class_name %> < ActiveRecord::Migration[5.1]
  def change
    create_table :<%= controller_file_name %> do |t|
      # t.string :name
    end
  end
end
