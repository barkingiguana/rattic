module Rattic
  class List < Struct.new(:client, :options)
    def run
      client.credentials.each do |credential|
        puts credential
      end
    end
  end
end
