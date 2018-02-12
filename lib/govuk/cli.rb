require "govuk/command"
require "govuk/docs"
require "govuk/http"
require "govuk/ssh"
require "govuk/string_extension"

module GOVUK
  class CLI < Thor
    desc "ssh <APPLICATION> <ENVIRONMENT>", "SSH into the server that <APPLICATION> lives on in <ENVIRONMENT> (integration by default)"
    def ssh(app_name, environment = "integration")
      environment_warning(environment)
      ssh = GOVUK::SSH.new(app_name, environment)

      run ssh.explanation, ssh.ssh_command
    end

    desc "console <APPLICATION> <ENVIRONMENT>", "Rails console for <APPLICATION> on <ENVIRONMENT> (integration by default). Use `govuk console .` for the current project"
    def console(app_name, environment = "integration")
      environment_warning(environment)
      ssh = GOVUK::SSH.new(app_name, environment)

      run ssh.explanation, ssh.console_command
    end

    desc "docs <APPLICATION>", "Open the docs for <APPLICATION>. Use `govuk docs .` for current project (https://docs.publishing.service.gov.uk/)"
    def docs(app_name = '.')
      command = GOVUK::Docs.new(app_name)

      run "Opening docs for #{command.app_name}", command.command
    end

    desc "vm COMMAND", "Run a command against the Vagrant VM. `vagrant ssh` by default."
    def vm(vagrant_command = "ssh")
      run "Opening Vagrant VM", "cd ~/govuk/govuk-puppet/development-vm && vagrant #{vagrant_command}"
    end

  private

    def environment_warning(environment)
      puts case environment
      when "production"
        "\n\n\n\n\t\t\t\t 🚨 YOU ARE ON PRODUCTION 🚨\n\n\n\n\n".red
      else
        "Environment: #{environment}".green
      end
    end

    def run(context, command)
      puts "#{context}\nRunning the following command:\n\n\t#{command.light_blue}\n\b"
      system command
    end
  end
end
