module API
  module V1
    class Controllers < Grape::API
      mount API::V1::<%= mount_path.pluralize %>
    end
  end
end
