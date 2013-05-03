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

