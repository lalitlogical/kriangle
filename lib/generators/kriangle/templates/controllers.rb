module API
  module V1
    class Controllers < Grape::API
      mount API::V1::<%= name.pluralize %>
    end
  end
end
