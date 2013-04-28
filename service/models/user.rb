class User
  include MongoMapper::Document
  safe

  class Address
    include MongoMapper::EmbeddedDocument

    key :address, String
    key :city, String
    key :state, String
    key :zip, String
    key :country, String
    key :student_id, String

    def empty?
      self.address.to_s.empty? and self.city.to_s.empty? and
          self.state.to_s.empty? and self.zip.to_s.empty? and self.country.to_s.empty?
    end

    def serializable_hash(options = {})
      super({except: :id}.merge(options))
    end

  end

  key :email, String, :required => true, :unique => true, :format => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/
  key :password, String, :required => true, :length => 40 # sha-1 hash
  key :first_name, String, :required => true
  key :last_name, String, :required => true
  key :address, Address
  timestamps!

  before_save do
    # replace id to email
    self.id = self.email
    # remove address if it is empty
    self.address = nil if self.address.nil? and self.address.empty?
  end

  def serializable_hash(options = {})
    super({except: :id}.merge(options))
  end

end
