require 'optparse'

module Rattic
  module Cli
    def self.run argv
      Manager.new(argv).run
    end

    class Options < Struct.new :argv
      DEFAULT_OPTIONS = {
        command: 'set',
      }

      def for_client
        {
          base_url: getopts[:base_url],
          verify_mode: getopts[:verify_mode],
          proxy: getopts[:proxy]
        }
      end

      def for_log_in
        {
          username: getopts[:username],
          password: getopts[:password]
        }
      end

      def for_command
        {
          check_mode: getopts[:check_mode],
          input: ARGF
        }
      end

      def command
        getopts[:command]
      end

      private

      def getopts
        @options ||= parse
      end

      def parse
        options = DEFAULT_OPTIONS.dup
        OptionParser.new do |opts|
          opts.banner = "Usage: #{File.basename($0)} [options]"

          opts.on("-b", "--base-url base-url", "Rattic base URL") do |v|
            options[:base_url] = v
          end

          opts.on("-p", "--password password", "Rattic password") do |v|
            options[:password] = v
          end

          opts.on("-s", "--self-signed-certificate") do |v|
            options[:verify_mode] = OpenSSL::SSL::VERIFY_NONE
          end

          opts.on("-u", "--username username", "Rattic username") do |v|
            options[:username] = v
          end

          opts.on("-c", "--check", "Check mode") do |v|
            options[:check_mode] = v
          end

          opts.on("-l", "--list", "List credentials") do |v|
            options[:command] = 'list'
          end

          opts.on("-x", "--proxy proxy", "Proxy to access Rattic") do |v|
            options[:proxy] = v
          end
        end.parse!
        options
      end
    end

    class Manager
      attr_accessor :client
      attr_accessor :options

      def initialize argv
        self.options = Options.new argv
        self.client = Client.new options.for_client
      end

      def run
        client.log_in options.for_log_in[:username], options.for_log_in[:password]
        client.public_send(options.command, options.for_command).run
      end
    end
  end
end
