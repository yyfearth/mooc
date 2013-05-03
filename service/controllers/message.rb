require '../models/message'

class MessageController < EntityController
  SINGLE_ID_URL = '/discussion/:id'
  SINGLE_URL = '/discussion'
  MULTIPLE_URL = '/discussions'
  GET_BY_COURSE_URLS = %w(/discussion/course/:id /course/:id/discussion)
  ADD_DISCUSSION_URL = '/discussion'

  @entity = Message.name
  @entity_name = Message.name

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

  delete '/discussion/:id/message/:message_id' do
    # TODO
    'delete a message'
  end

  # HACK: for debug
  get '/messages/all' do
    ok(Message.all)
  end
end
