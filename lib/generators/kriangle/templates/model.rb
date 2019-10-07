# frozen_string_literal: true

class <%= class_name %> < ApplicationRecord
  <%- if reference -%>
  belongs_to :<%= user_class %><%= counter_cache ? ', counter_cache: true' : '' %>
  <%- end -%>
  <%- if self_reference -%>
  belongs_to :<%= parent_association_name %>, :class_name => '<%= class_name %>', optional: true
  has_many :<%= child_association_name %>, :class_name => '<%= class_name %>', :foreign_key => 'parent_id'
  <%- end -%>
  <%- for polymorphic in @options[:polymorphics] -%>
  belongs_to :<%= polymorphic %>, polymorphic: true
  # use below into referenced model
  # has_many :<%= polymorphic.gsub('able','').pluralize %>, as: :<%= polymorphic %>, dependent: :destroy
  <%- end -%>
  <%- for parent_model in @options[:references] -%>
    <%- if !reference || parent_model != user_class -%>
  belongs_to :<%= parent_model %>
    <%- end -%>
  <%- end -%>
  <%- if @options[:attributes].size != 0 -%>

  # validation's on columns
  validates :<%= @options[:attributes].join(', :') %>, presence: true
  <%- end -%>
end
