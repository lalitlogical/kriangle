# frozen_string_literal: true

<% if custom_orm == 'Mongoid' %>
class ApplicationRecord
<% else %>
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
<% end %>
end
