class Credential < Struct.new :client, :title, :user, :group
  def <=> other
    sort_key <=> other.sort_key
  end
  include Comparable

  def add value
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
    "Credential #{client.base_url},#{title},#{user},#{group}"
  end

  def sort_key
    [ title, user, group ].join('---')
  end
end
