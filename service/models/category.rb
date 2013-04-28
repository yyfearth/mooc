class Category
  include MongoMapper::Document
  safe

  key :name, String, :required => true, :unique => true

  timestamps!

end
