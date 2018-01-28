class Create<%= controller_class_name %> < ActiveRecord::Migration[5.1]
  def change
    create_table :<%= controller_file_name %> do |t|
      <%- for attribute in model_attributes -%>
        t.<%= attribute.type %> :<%= attribute.name %>
      <%- end -%>
      <%- unless options[:skip_timestamps] -%>
        t.timestamps
      <%- end -%>
    end
  end
end
