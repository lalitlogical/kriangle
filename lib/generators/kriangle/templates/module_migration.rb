class Create<%= class_name.pluralize %> < ActiveRecord::Migration[5.2]
  def change
    create_table :<%= controller_file_name %> do |t|
      <%- for ma in model_associations.select { |ma| ma.association_type == 'belongs_to' }.uniq { |ma| ma.association_name } -%>
      t.references :<%= ma.association_name %>, foreign_key: true
      <%- end -%>
      <%- if self_reference -%>
      t.references :<%= parent_association_name %>, foreign_key: true
      <%- end -%>
      <%- for attribute in @polymorphics -%>
      t.references :<%= attribute.name %>, polymorphic: true
      <%- end -%>

      <%- for attribute in @attributes -%>
      t.<%= attribute.type || 'string'  %> :<%= attribute.name %><%= ", default: #{attribute.default.gsub('~', "'")}" unless attribute.default.nil? %>
      <%- end -%>

      <%- unless skip_timestamps -%>
      t.timestamps
      <%- end -%>
    end
  end
end
