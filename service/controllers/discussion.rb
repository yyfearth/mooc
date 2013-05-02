class DiscussionController < EntityController
  SINGLE_ID_URL = '/discussion/:id'
  GET_BY_COURSE_URL = '/discussion/course/:id'
  ADD_DISCUSSION_URL = '/discussion'

  get SINGLE_ID_URL do
    p params
    err 400, 'BAD_REQUEST', 'No id' if params[:id].nil?

    p 'yes'
  end

  get GET_BY_COURSE_URL do
    # TODO
    'GET_BY_COURSE_URL'
  end

  get '/discussions/' do
    # TODO
    'search api'
  end

  post '/discussion' do
    request_content = request.body.read

    begin
      json = JSON.parse(request_content)

      err 400, 'BAD_REQUEST', "The request data doesn't match expected format" unless %w(title created_by).all? { |k| json.has_key?(k) }

      discussion = Discussion.create(
          {
              title: json['title'],
              created_by: json['created_by'],
          }
      )
      created discussion
    rescue MongoMapper::DocumentNotValid => e
      invalid_entity! e
    rescue JSON::ParserError => e
      warn e.backtrace[0]
      warn e.inspect
      err 400, 'BAD_REQUEST', 'Cannot parse the request data' if request_content
    end
  end

  put SINGLE_ID_URL do
    # TODO
    'update discussion'
  end

  delete SINGLE_ID_URL do
    # TODO
    'delete discussion'
  end

  get '/discussion/:id/messages' do
    # TODO
    'search messages'
  end

  get '/discussion/:id/message/:message_id' do
    # TODO
    'get a messages'
  end

  post '/discussion/:id/message' do
    # TODO
    'create a message'
  end

  put '/discussion/:id/message/:message_id' do
    # TODO
    'update a message'
  end

  delete '/discussion/:id/message/:message_id' do
    # TODO
    'delete a message'
  end

  # HACK: for debug
  get '/discussions/all' do
    ok Discussion.all
  end

  get '/messages/all' do
    ok Message.all
  end
end
