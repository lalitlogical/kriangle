class CreateAuthentications < ActiveRecord::Migration<%= "[#{Rails::VERSION::STRING[0..2]}]" if Rails::VERSION::MAJOR > 4 %>
  def change
    create_table :authentications do |t|
      t.references :<%= @underscored_name %>
      t.text :client_id
      t.text :token
    end
  end
end
