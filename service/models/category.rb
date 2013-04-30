class Category
  include MongoMapper::Document
  safe

  key :name, String,
      :required => true,
      :unique => true,
      :case_sensitive => false
  timestamps!

  DUP_MSG = 'has already been taken'

  after_validation do
    # replace id to name equivalent
    self.id = self.name.downcase.gsub /\s/, '_'
    # check duplication
    if Category.find self.id
      self.errors.add :id, :taken, :message => "'#{self.id}' #{DUP_MSG}"
      raise MongoMapper::DocumentNotValid.new self
    end
  end

end
