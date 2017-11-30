module Doorbell
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("../../templates", __FILE__)

    desc "Creates a Doorbell initializer."

    def copy_initializer
      template 'doorbell.rb', 'config/initializers/doorbell.rb'
    end
  end
end
