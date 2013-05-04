class MessageController < EntityController
  SINGLE_ID_URL = '/message/:id'
  SINGLE_URL = '/message'
  MULTIPLE_URL = '/messages'
  SEARCH_BY_DISCUSSION_URL = '/discussion/:id/messages'
  GET_BY_DISCUSSION_URL = '/discussion/:id/message'

  @entity = Message.name
  @entity_name = Message.name

  # Store the id globally.
  [GET_BY_COURSE_URLS, SINGLE_ID_URL].each do |url|
    before url do
      @id = params[:id]
      puts 'id = ' << @id.to_s
    end
  end

  get '/message/:id/messages' do
    # TODO
    'search messages'
  end

  get '/message/:id/message/:message_id' do
    # TODO
    'get a messages'
  end

  post '/message/:id/message' do
    # TODO
    'create a message'
  end

  delete '/message/:id/message/:message_id' do
    # TODO
    'delete a message'
  end

# HACK: for debug
get '/messages/all' do
  ok(Message.all)
end

