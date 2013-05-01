class EntityController < Sinatra::Base
  DUP_MSG = 'has already been taken'

  helpers do

    def do_search(collection, params, options = {})
      query = {}
      unless options[:fields].to_a.empty?
        options[:fields].each { |field| query[field] = params[field] unless params[field].to_s.blank? }
      end
      unless options[:q].to_a.empty? || params[:q].to_s.blank?
        q = /#{params[:q]}/i
        query[:$or] = options[:q].map { |field| {field => q} }
      end
      query[:created_at.gte] = Time.parse(params[:created_from]) unless params[:created_from].to_s.empty?
      query[:created_at.lte] = Time.parse(params[:created_to]) unless params[:created_to].to_s.empty?
      query[:updated_at.gte] = Time.parse(params[:updated_from]) unless params[:updated_from].to_s.empty?
      query[:updated_at.lte] = Time.parse(params[:updated_to]) unless params[:updated_to].to_s.empty?
      offset = params[:offset] || 0
      limit = params[:limit] || 20
      order_by = params[:order_by] || :created_by.desc
      collection.where(query).order(order_by).offset(offset).limit(limit)
    end

    def is_param_on?(name)
      !params[name].to_s[/true|yes|on|1/i].nil?
    end

    ### validation

    def invalid_entity!(e)
      puts e.inspect #, e.backtrace
      matched = /\b(?<key>\w+)(?: '.+?')? #{DUP_MSG}/.match e.message
      if matched
        conflict "#{matched[:key]}_DUPLICATED", e.message
      else
        bad_request 'INVALID_DOCUMENT', e.message
      end
    end

    def entity_not_found?(entity = @entity, id = @id)
      not_found "#{@entity_name}_NOT_FOUND", "#{@entity_name} '#{id}' is not found" if entity.nil?
    end

    def id_not_matched?(json)
      url_id = @id || params[:id]
      json_id = json['id']
      bad_request 'ID_NOT_MATCH', "Id in URL is not matched '#{url_id}' != '#{json_id}'" if url_id != json_id
    end

    ### results

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
          error: error_code.upcase,
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

  before { content_type :json }
  not_found { err 404, 'NOT_FOUND', 'Not found' }
  error do
    e = env['sinatra.error']
    err 500, 'UNEXPECTED_ERROR', e.message
  end

end
