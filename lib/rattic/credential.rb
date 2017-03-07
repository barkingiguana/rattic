class Credential < Struct.new(:title, :user, :group)
  def <=> other
    sort_key <=> other.sort_key
  end
  include Comparable

  def sort_key
    [ title, user, group ].join('---')
  end
end
