class Credential
  attr_accessor :client, :title, :user, :group, :id

  def initialize client, title, user, group, id = nil
    self.client = client
    self.title = title
    self.user = user
    self.group = group
    self.id = id
  end

  def <=> other
    sort_key <=> other.sort_key
  end
  include Comparable

  def add value
    raise "Already added!" unless id.nil?
    client.with_agent do |agent|
      agent.get base_url
      agent.page.link_with(text: 'Add New').click
      creds_form = agent.page.form_with(action: '/cred/add/')
      creds_form.field_with(name: 'title').value = title
      creds_form.field_with(name: 'username').value = user
      creds_form.field_with(name: 'password').value = desired
      creds_form.field_with(name: 'group').option_with(text: group).click
      agent.submit creds_form
    end
  end

  def set value
    return add desired unless exists?
    raise "Not yet implemented"
  end

  def value
    raise "Not yet implemented"
  end

  def exists?
    client.credentials.any? do |c|
      c.title == title && c.user == user && c.group == group
    end
  end

  def matches? expected
    value == expected
  end

  def to_s
    "Credential #{url} | #{group} / #{title} / #{user}"
  end

  def url
    "#{client.base_url}#{path}"
  end

  def path
    "/cred/detail/#{id}/"
  end

  def to_json
    client.visit("/api/v1/cred/#{id}/?format=json").body
  end

  def to_hash
    JSON.parse to_json
  end

  def sort_key
    [ group, title, user ].join('---')
  end
end
