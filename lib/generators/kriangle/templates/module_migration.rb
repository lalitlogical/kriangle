class Create<%= controller_class_name %> < ActiveRecord::Migration[5.2]
  def change
    create_table :<%= controller_file_name %> do |t|
      <%- if reference -%>
      t.references :<%= user_class %>, foreign_key: true
      <%- end -%>
      <%- if self_reference -%>
      t.references :parent, index: true
      <%- end -%>
      <%- for attribute in @polymorphics -%>
      t.references :<%= attribute.name %>, polymorphic: true
      <%- end -%>
      <%- for attribute in @references.reject { |a| reference && a.name == user_class } -%>
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
