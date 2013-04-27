class User
  include MongoMapper::Document
  safe

  key :email, String, :required => true
  key :password, String, :required => true
  key :first_name, String, :required => true
  key :last_name, String, :required => true
  key :address, Address

  timestamps!

  # cannot be set by massive assignment
  # need to use: `user.password = json['password']`
  #attr_protected :password

  before_save do
    # replace id to email
    self.id = self.email
    # remove address if it is empty
    self.address = nil if self.address != nil and self.address.empty?
  end

  def serializable_hash(options = {})
    super({:except => [:id, :password]}.merge(options))
  end

end

User.ensure_index :email, :unique => true
