require 'uri'
require 'securerandom'

module Rattic
  class Client
    attr_accessor :agent
    private :agent=, :agent

    attr_accessor :base_url
    private :base_url=

    def initialize(proxy: nil, base_url:, verify_mode: OpenSSL::SSL::VERIFY_PEER)
      self.agent = Mechanize.new do |a|
        a.verify_mode = verify_mode
        if proxy
          uri = URI.parse proxy
          a.set_proxy uri.host, uri.port
        end
        a.user_agent = "Rattic Client v#{Rattic::VERSION}"
      end
      self.base_url = base_url
    end

    def log_in username, password
      agent.get base_url
      login_form = agent.page.form_with action: '/account/login/?next='
      login_form.field_with(:name => "auth-username").value = username
      login_form.field_with(:name => "auth-password").value = password
      agent.submit login_form
    end

    def ensure_credential_exists title, user, group
      return if credential_defined_for? title, user, group
      agent.get base_url
      current_page.link_with(text: 'Add New').click
      creds_form = current_page.form_with(action: '/cred/add/')
      creds_form.field_with(name: 'title').value = title
      creds_form.field_with(name: 'username').value = user
      creds_form.field_with(name: 'password').value = SecureRandom.uuid
      creds_form.field_with(name: 'group').option_with(text: group).click
      agent.submit creds_form
    end

    def credential_defined_for? title, user, group
      visible_credentials.any? do |c|
        c.title == title && c.user == user && c.group == group
      end
    end

    private

    def visible_credentials
      @visible_credentials ||= fetch_credentials
    end

    def fetch_credentials
      agent.get base_url
      credentials = []
      loop do
        credentials += read_credentials
        next_link = current_page.link_with(text: 'Next')
        break if next_link.node.parent['class'] =~ /disabled/
        next_link.click
      end
      credentials.sort!
      credentials
    end

    def read_credentials
      el = current_page.link_with(text: 'Add New').node
      el = el.parent while el.name != 'table'
      credentials = []
      el.search('tbody tr').each do |row|
        title, user, group = row.search('td')[1,3].to_a.map { |e| e.text.to_s.strip }
        credentials << Credential.new(title, user, group)
      end
      sleep 0.5 # Don't melt Rattic
      credentials
    end

    def current_page
      agent.page
    end
  end
end
