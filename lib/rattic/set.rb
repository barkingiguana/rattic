module Rattic
  class Set < Struct.new(:client, :options)
    def run
      each_credential do |credential, desired = nil|
        if check_mode?
          message = "[#{credential.to_s}] exists: #{credential.exists?}"
          if desired
            message << ", value matches: #{credential.matches? desired}"
          end
          puts message
        else
          desired ||= SecureRandom.uuid
          credential.set desired
        end
      end
    end

    def each_credential
      options[:input].each_line do |line|
        title, user, env, desired = *line.split(/,/, 4).map(&:strip)
        credential = Credential.new client, title, user, env
        yield credential, desired
      end
    end

    private

    def check_mode?
      options[:check_mode]
    end
  end
end
