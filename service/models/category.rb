class Category
  include MongoMapper::Document
  safe

  key :name, String, :required => true
  key :address, Address

  timestamps!

end

User.ensure_index :name, :unique => true
