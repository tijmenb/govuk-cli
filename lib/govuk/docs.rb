module GOVUK
  class Docs < Command
    def command
      "open https://docs.publishing.service.gov.uk/apps/#{app_name}.html"
    end
  end
end
