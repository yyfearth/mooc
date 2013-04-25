require 'mongo_mapper'

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
    @id = @email
    # remove address if it is empty
    @address = nil if @address != nil and @address.empty?
  end

  def serializable_hash(options = {})
    super({:except => [:id, :password]}.merge(options))
  end

end

User.ensure_index :email, :unique => true
