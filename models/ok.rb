require 'json'

class OK
  def initialize(message)
    @message = message
  end

  def to_json(*a)
    {
        :ok => 'OK',
        :message => @message
    }.to_json(*a)
  end

  def self.create(message, *a)
    new = self.new message
    new.to_json *a
  end
end
