class CreateAuthentications < ActiveRecord::Migration[5.1]
  def change
    create_table :authentications do |t|
      t.references :<%= @underscored_name %>
      t.text :token
    end
  end
end
