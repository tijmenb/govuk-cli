module GOVUK
  class Command
    attr_reader :app_name

    def initialize(app_name)
      @app_name = app_name == '.' ? current_directory_which_could_be_app_name : app_name
    end

  private

    def current_directory_which_could_be_app_name
      Dir.pwd.split('/').last
    end
  end
end
