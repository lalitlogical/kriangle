# frozen_string_literal: true

class <%= class_name %> < ApplicationRecord
  <%- if custom_orm == 'Mongoid' -%>
  include Mongoid::Document
  include Mongoid::Timestamps

  <%- unless skip_tips -%>
  # Add your fields below
  # field :title, type: String
  # field :content, type: String, default: ""
  # field :views, type: Integer, default: 0
  <%- end -%>
  <%- end -%>
  <%- for polymorphic in @options[:polymorphics] -%>
  belongs_to :<%= polymorphic %>, polymorphic: true
  # use below into referenced model
  # has_many :<%= polymorphic.gsub('able','').pluralize %>, as: :<%= polymorphic %>, dependent: :destroy
  <%- end -%>
  <%- if reference -%>
  belongs_to :<%= user_class %><%= counter_cache ? ', counter_cache: true' : '' %>
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
