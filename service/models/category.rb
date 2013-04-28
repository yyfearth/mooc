class Category
  include MongoMapper::Document
  safe

  key :name, String, :required => true

  timestamps!

end

Category.ensure_index :name, :unique => true
