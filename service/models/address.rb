require 'mongo_mapper'

class Address
  include MongoMapper::EmbeddedDocument

  key :address, String
  key :city, String
  key :state, String
  key :zip, String
  key :country, String

  def empty?
    self.address.to_s.empty? and self.city.to_s.empty? and
        self.state.to_s.empty? and self.zip.to_s.empty? and self.country.to_s.empty?
  end

  def serializable_hash(options = {})
    super({except: :id}.merge(options))
  end

end
