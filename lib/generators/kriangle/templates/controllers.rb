module API
  module <%= wrapper.capitalize %>
    class Controllers < Grape::API
      mount API::<%= wrapper.capitalize %>::<%= mount_path.pluralize %>
    end
  end
end
