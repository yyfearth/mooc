class DiscussionController < EntityController
  GET_URL = '/discussion/:id'
  GET_BY_COURSE_URL = '/discussion/course/:id'
  ADD_DISCUSSION_URL = '/discussion'

  get GET_URL do
    'GET_URL'
  end

  get GET_BY_COURSE_URL do
    'GET_BY_COURSE_URL'
  end

  post '/discussion' do
    request_content = request.body.read

    begin
      json = JSON.parse(request_content)
      discussion = Discussion.create
      created discussion.to_json
    rescue MongoMapper::DocumentNotValid => e
      invalid_entity! e
    rescue JSON::ParserError => e
      err 400, 'BAD_REQUEST', 'Cannot parse the request data' if request_content
    end
  end

  # HACK: for debug
  get '/discussions/all' do
    ok Discussion.all
  end

  get '/messages/all' do
    ok Message.all
  end
end
