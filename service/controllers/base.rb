class EntityController < Sinatra::Base
  DUPLICATE_MESSAGE = 'has already been taken'

  helpers do
    # do_search -> Array
    #
    # A generic method used to build search query and produce search results.
    #
    # @param collection
    #   the collection for searching
    # @param params
    #   the parameters sent by the client
    # @param options
    #   the optional parameters used to build MongoDB query.
    #   options[:q] is an array which contains fields you want to select for *partial match* from params as OR relationship.
    #   options[:fields] is an array which contains fields you want to select for *exact match* from params as AND relationship.
    #
    # = Example
    #   ```
    #   params = {
    #     :q => 'test'
    #     :title => 'dr',
    #     :name => 'john',
    #     :created_from => '2013-05-03T08:32:34-07:00',
    #   }
    #
    #   options = {
    #     :q => [:title],
    #     :fields => {
    #       :age.gte => 18,
    #       :gender => 'male',
    #     }
    #   }
    #
    #   query = {
    #     :age.gte => 18,
    #     :gender => 'male',
    #     :title => 'dr',
    #     :$or => [{:title => /test/i}]
    #     :$created_at.gte => '2013-05-03T08:32:34-07:00',
    #   }
    #   ```
    #
    #
    #   The method will generate `created...` and `updated...` operators if `created...` or `updated...` symbols present in the params variable.
    #
    #   There are other parameters will be treated specially:
    #   * :offset => 0
    #   * :limit => 20
    #   * :order_by => :created_by.desc
    def do_search(collection, params, options = {}) # OPTIMIZE: the variable names are too vague.
      query = {}

      unless options[:fields].to_a.empty?
        options[:fields].each { |field| query[field] = params[field] unless params[field].to_s.blank? }
      end

      unless options[:q].to_a.empty? || params[:q].to_s.blank?
        q = /#{params[:q]}/i
        fields = options[:q]
        if fields.length > 1
          query[:$or] = options[:q].map { |field| {field => q} }
        elsif query[fields[0]].to_s.blank?
          query[fields[0]] = q
        end
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

    # to test whether a flag parameter is on (default on or off)
    def is_param_on?(name, default = false)
      if default # default is on, means the the flag is on, when it not exists or not set to false/no/off/0
        params[name].nil? || params[name].to_s[/\A(:?false|no|off|0)\Z/i].nil?
      else # default is off, means the the flag is on, only when it exists and set to true/yes/on/1
        !params[name].to_s[/\A(:?true|yes|on|1)\Z/i].nil?
      end
    end

    ### validation

    def invalid_entity(e)
      warn e.inspect #, e.backtrace
      matched = /\b(?<key>\w+)(?: '.+?')? #{DUPLICATE_MESSAGE}/.match e.message
      if matched
        conflict "#{matched[:key]}_DUPLICATED", e.message
      else
        bad_request 'INVALID_DOCUMENT', e.message
      end
    end

    # halt and return not found error json when the given entity is nil
    def not_found_if_nil(entity = @entity, id = @id)
      not_found("#{@entity_name}_NOT_FOUND", "#{@entity_name} '#{id}' is not found") if entity.nil?
    end

    # halt and return id not match error json when the id in given json and params of url is not the same
    def id_not_matched?(json)
      url_id = @id || params[:id]
      json_id = json['id']
      bad_request 'ID_NOT_MATCH', "Id in URL is not matched '#{url_id}' != '#{json_id}'" if url_id != json_id
    end

    ### results

    # return created 201 with entity json and location url
    # path the entity's url relative to the root, e.g. /user/xxx
    def created(entity, path = "/#{entity.class.name.downcase}/#{entity.id}")
      status 201
      headers 'Location' => url(path)
      entity.to_json
    end

    # return ok 200 with entity json or ok json
    # ok json is a json with a message to indicate a operation is done successfully without return entity json
    def ok(entity)
      if entity.is_a? String # if a string is given, halt and return a ok json
        halt({ok: 'OK', message: entity}.to_json)
      else # if an object (entity/ies) is given, then return the json without halt
        entity.to_json
      end
    end

    # halt and return error json
    # status_code: the http status code, e.g. 400, 500
    # error_code: the string code for the specified error, e.g. USER_NOT_FOUND
    # message: a readable message that detailed described the error
    def err(status_code, error_code, message)
      error status_code, {
          error: error_code.upcase,
          message: message
      }.to_json
    end

    # shortcuts for err

    def internal_error(error_code, message)
      err 500, error_code, message
    end

    def id_not_found(class_name, id)
      json = {error: 'NOT_FOUND', message: "Cannot find a #{class_name} where id = #{id}"}.to_json
      error 404, json
    end

    def not_found(error_code = 'NOT_FOUND', message)
      err(404, error_code, message)
    end

    def bad_request(error_code = 'BAD_REQUEST', message)
      err 400, error_code, message
    end

    def conflict(error_code, message)
      err 409, error_code, message
    end
  end

  # Store the request JSON globally.
  before '*' do
    begin
      request_content = request.body.read
      puts request_content.empty? ? 'No content' : 'Request content = ' << request_content
      @json = JSON.parse(request_content) unless request_content.to_s.empty?
    rescue JSON::ParserError => e
      warn e.backtrace[0]
      warn e.inspect
      err 400, 'BAD_REQUEST', 'Cannot parse the request data' if request_content
    end
  end

  before { content_type :json }

  # FIXME: not sure why the following doesn't work.
  error do
    e = env['sinatra.error']
    err 500, 'UNEXPECTED_ERROR', e.message
  end

  error MongoMapper::DocumentNotValid do |e|
    warn e.to_s
    warn e.backtrace[0]
    invalid_entity(e)
  end

  error 500 do |e|
    warn e.to_s
    warn e.backtrace[0]
    err 500, 'UNEXPECTED_ERROR', e.message
  end

end
