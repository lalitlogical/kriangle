class Create<%= controller_class_name %> < ActiveRecord::Migration[5.1]
  def change
    create_table :<%= controller_file_name %> do |t|
      <%- if reference -%>
      t.references :<%= user_class %>, foreign_key: true
      <%- end -%>
      <%- for attribute in @polymorphics -%>
      t.references :<%= attribute.name %>, polymorphic: true
      <%- end -%>
      <%- for attribute in @references -%>
      t.references :<%= attribute.name %>, foreign_key: true
      <%- end -%>

      <%- for attribute in @attributes -%>
      t.<%= attribute.type || 'string'  %> :<%= attribute.name %>
      <%- end -%>
      <%- unless skip_timestamps -%>
      t.timestamps
      <%- end -%>
    end
  end
end
