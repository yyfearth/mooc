require 'mongo_mapper'

class Address
  include MongoMapper::EmbeddedDocument

  key :address, String
  key :city, String
  key :state, String
  key :zip, String
  key :country, String

  def empty?
    @address.to_s.empty? and @city.to_s.empty? and
        @state.to_s.empty? and @zip.to_s.empty? and @country.to_s.empty?
  end

  def serializable_hash(options = {})
    super({:except => :id}.merge(options))
  end

end
