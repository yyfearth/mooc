require 'json'

class Error
  def initialize(error, message)
    @error = error
    @message = message
  end

  def to_json(*a)
    {
        :error => @error,
        :message => @message
    }.to_json(*a)
  end

  def self.create(error, message, *a)
    new = self.new error, message
    new.to_json *a
  end
end
