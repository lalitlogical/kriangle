class CreateAvatars < ActiveRecord::Migration<%= "[#{Rails::VERSION::STRING[0..2]}]" if Rails::VERSION::MAJOR > 4 %>
  def change
    create_table :avatars do |t|
      t.references :<%= underscored_user_class %>, foreign_key: true

      t.text :image
      t.integer :sorting, default: 0
    end
  end
end
