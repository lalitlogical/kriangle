class Create<%= class_name.pluralize %> < ActiveRecord::Migration[5.2]
  def change
    create_table :<%= controller_file_name %> do |t|
      <%- for ma in model_associations.select { |ma| ma.association_type == 'belongs_to' }.uniq { |ma| ma.association_name } -%>
        <%- if ma.foreign_key.present? -%>
      t.integer :<%= ma.foreign_key %>, index: true
        <%- else -%>
      t.references :<%= ma.association_name %><%= ", foreign_key: true" if ma.class_name.blank? %>
        <%- end -%>
      <%- end -%>
      <%- if self_reference -%>
      t.references :<%= parent_association_name %>, index: true
      <%- end -%>
      <%- for attribute in @polymorphics -%>
      t.references :<%= attribute.name %>, polymorphic: true
      <%- end -%>
      <%- for attribute in @attributes -%>
        <%- if attribute.type == 'array' -%>
          <%- if database == 'sqlite3' -%>
      t.text :<%= attribute.name %>
          <%- else -%>
      t.text :<%= attribute.name %>, array: true, default: []
          <%- end -%>
        <%- else -%>
      t.<%= attribute.type || 'string'  %> :<%= attribute.name %><%= ", default: #{attribute.default.gsub('~', "'")}" unless attribute.default.nil? %>
        <%- end -%>
      <%- end -%>
      <%- unless skip_timestamps -%>
      t.timestamps
      <%- end -%>
    end
  end
end
