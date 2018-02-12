module GOVUK
  class SSH < Command
    attr_reader :environment

    def initialize(app_name, environment)
      super(app_name)
      @environment = environment
    end

    def explanation
      puts "Application '#{app_name}' runs on '#{machine_class}' machines."
    end

    def ssh_command(subcommand_on_server = nil)
      if subcommand_on_server
        subcommand_on_server = "'#{subcommand_on_server}'"
      end

      "ssh -A -t tijmenbrommet@#{jumpbox} 'ssh `govuk_node_list -c #{machine_class} --single-node` #{subcommand_on_server}'"
    end

    def console_command
      ssh_command("govuk_app_console #{app_name}")
    end

  private

    def jumpbox
      case environment
      when "integration"
        "jumpbox.integration.publishing.service.gov.uk"
      when "staging"
        "jumpbox.staging.publishing.service.gov.uk"
      when "production"
        "jumpbox.publishing.service.gov.uk"
      end
    end

    def machine_class
      machine_classes = case environment
      when "integration"
        puppet_classes_on_integration
      when "staging", "production"
        puppet_classes
      end

      # Don't SSH into the draft machines.
      machine_classes = machine_classes.reject { |s| s.start_with?("draft") }

      if machine_classes.none?
        raise "No machine class found for #{app_name}"
      elsif machine_classes.count > 1
        raise "Found multiple classes for #{app_name} and I can't handle that yet."
      end

      machine_classes.first
    end

    def puppet_classes_on_integration
      machines_in_aws.map do |puppet_class, keys|
        if keys["apps"].include?(app_name)
          puppet_class
        end
      end.compact
    end

    def puppet_classes
      machines_on_carrenza.map do |puppet_class, keys|
        if keys["apps"].include?(app_name)
          puppet_class
        end
      end.compact
    end

    def machines_in_aws
      yaml = HTTP.get_yaml('https://raw.githubusercontent.com/alphagov/govuk-puppet/master/hieradata_aws/common.yaml')
      yaml["node_class"]
    end

    def machines_on_carrenza
      yaml = HTTP.get_yaml('https://raw.githubusercontent.com/alphagov/govuk-puppet/master/hieradata/common.yaml')
      yaml["node_class"]
    end
  end
end
