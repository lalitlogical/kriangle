class ActiveSerializer < ActiveModel::Serializer
  <%- if custom_orm == 'Mongoid' -%>
  def id
    object._id.to_s
  end
  <%- end -%>
end
