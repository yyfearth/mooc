## Model for User and Address

class Address
  include MongoMapper::EmbeddedDocument

  key :address, String
  key :city, String
  key :state, String
  key :zip, String
  key :country, String
  key :student_id, String

  def empty?
    self.address.to_s.empty? && self.city.to_s.empty? &&
        self.state.to_s.empty? && self.zip.to_s.empty? && self.country.to_s.empty?
  end

  def serializable_hash(options = {})
    super({except: :id}.merge(options))
  end

end

class User
  include MongoMapper::Document

  key :email, String,
      required: true,
      unique: true,
      length: 255,
      format: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/
  key :password, String,
      #required: true,
      length: 40,
      format: /\A[0-9a-f]{40}\Z/ # sha-1 hash
  key :first_name, String #, required: true
  key :last_name, String #, required: true
  key :address, Address
  timestamps!

  DUP_MSG = 'has already been taken'

  before_validation do
    self.email.downcase! # ignore case
  end

  before_create do
    # replace id to email
    self.id = self.email
    # remove address if it is empty
    unless self.address.nil?
      self.address = nil if !self.address.is_a?(Address) || self.address.empty?
    end
  end

  def serializable_hash(options = {})
    super({except: :id}.merge(options))
  end

end

User.ensure_index :email, unique: true
