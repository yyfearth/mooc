class Controller < Sinatra::Base
  helpers do

    def do_search(collection, params)
      offset = params[:offset] || 0
      limit = params[:limit] || 20
      order_by = params[:order_by] || :created_by.desc
      created_from = params[:created_from]
      created_to = params[:created_to]
      updated_from = params[:updated_from]
      updated_to = params[:updated_to]
      where = {}
      where[:created_at.gte] = Time.parse(created_from) unless created_from.to_s.empty?
      where[:created_at.lte] = Time.parse(created_to) unless created_to.to_s.empty?
      where[:updated_at.gte] = Time.parse(updated_from) unless updated_from.to_s.empty?
      where[:updated_at.lte] = Time.parse(updated_to) unless updated_to.to_s.empty?
      collection.where(where).order(order_by).offset(offset).limit(limit)
    end

    def created(entity, path = "/#{entity.class.name.downcase}/#{entity.id}")
      status 201
      headers 'Location' => url(path)
      entity.to_json
    end

    def ok(entity)
      if entity.is_a? String
        halt({ok: 'OK', message: entity}.to_json)
      else
        entity.to_json
      end
    end

    def err(status_code, error_code, message)
      error status_code, {
          error: error_code,
          message: message
      }.to_json
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

  end

  before do
    content_type :json
  end

  not_found do
    err 404, 'NOT_FOUND', 'Not found'
  end

end

class EntityController < Controller

  helpers do

    def duplicated!(key, value)
      conflict "#{@entity_name.upcase}_#{key.upcase}_DUPLICATED", "#{@entity_name} with #{key.downcase} '#{value}' already exists"
    end

    def entity_not_found?(entity)
      not_found "#{@entity_name.upcase}_NOT_FOUND", "#{@entity_name} with id '#{@id}' is not found" if entity.nil?
    end

    def no_id_in_json?(json)
      bad_request 'NO_ID', 'ID is required in JSON' if json['id'].to_s.empty?
    end

    def id_not_matched?(json)
      url_id = @id || params[:id]
      json_id = json['id']
      bad_request 'ID_NOT_MATCH', "ID in URL is not matched '#{url_id}' != '#{json_id}'" if url_id != json_id
    end

  end

end
