## Modal for Course with Participant

class Participant
  include MongoMapper::EmbeddedDocument

  key :email, String,
      required: true,
      length: 255,
      format: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/
  key :role, Symbol, default: :STUDENT #, in: [:STUDENT, :INSTRUCTOR, :OWNER, :ASSISTANT, :GUEST]
  key :status, Symbol, default: :ENROLLED #, in: [:ENROLLED, :DROPPED]

  before_validation do
    self.email.downcase!
  end

  def serializable_hash(options = {})
    super({except: :id}.merge(options))
  end

end

class Course
  include MongoMapper::Document

  key :title, String, required: true, unique: true, length: 255
  key :description, String, required: true
  key :category_id, String, required: true
  many :participants
  key :status, Symbol, default: :OPENED #, in: [:OPENED, :CLOSED, :DELETED]
  key :created_by, String, required: true # only email for ref
  key :updated_by, String # only email for ref
  timestamps!

  before_create do # auto add creator to participants as owner
    owner = Participant.new email: self.created_by, role: :OWNER, status: :ENROLLED
    users = self.participants
    if users.nil?
      self.participants = [owner]
    elsif users.length == 0 || (users.index { |p| p.email == owner.email }).nil?
      users << owner
    end
  end

  before_save do
    self.participants.uniq! { |p| p.email }
  end

end

Course.ensure_index :title
Course.ensure_index :category_id
Course.ensure_index :'participants.email'
