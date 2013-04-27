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

class SearchParams
  attr_reader :offset, :limit, :order_by, :where

  def initialize(params)
    @offset = params[:offset] || 0
    @limit = params[:limit] || 20
    @order_by = params[:order_by] || :created_by.desc
    created_from = params[:created_from]
    created_to = params[:created_to]
    updated_from = params[:updated_from]
    updated_to = params[:updated_to]
    @where = {}
    @where[:created_at.gte] = Time.parse(created_from) unless created_from.to_s.empty?
    @where[:created_at.lte] = Time.parse(created_to) unless created_to.to_s.empty?
    @where[:updated_at.gte] = Time.parse(updated_from) unless updated_from.to_s.empty?
    @where[:updated_at.lte] = Time.parse(updated_to) unless updated_to.to_s.empty?
  end
end

before do
  content_type 'application/json;charset=utf-8'
end

def created(entity, path = "/#{entity.class.name.downcase}/#{entity.id}")
  status 201
  headers 'Location' => url(path)
  entity.to_json
end

def ok(entity)
  if entity.is_a? String
    halt OK.create entity
  else
    entity.to_json
  end
end

def err(status_code, error_code, message)
  error status_code, Error.create(error_code, message)
end

def internal_error(error_code, message)
  err 500, error_code, message
end

def not_found(error_code, message)
  err 400, error_code, message
end

def bad_request(error_code, message)
  err 400, error_code, message
end

def conflict(error_code, message)
  err 409, error_code, message
end
