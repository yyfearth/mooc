MESSAGE_URL = '/discussion/:discussion_id/message'
MESSAGES_URL = '/messages'
MESSAGE_ID_URL = "#{MESSAGE_URL}/:id"
MESSAGE_COURSE_URLS = ['/message/course/:id', MESSAGE_URL]

before "#{MESSAGE_URL}*" do
  @entity_name = Message.name
end

MESSAGE_COURSE_URLS.concat([MESSAGE_ID_URL]).each do |url|
  before url do
    @id = params[:id]
    @discussion_id = params[:discussion_id]
    @entity_name = Message.name
    puts 'id = ' << @id.to_s
  end
end

get %r'/discussions?/:discussion_id/messages?/:id' do
  discussion = Discussion.find_by_id(@id)

  not_found_if_nil!(discussion)

  ok(message)
end

MESSAGE_COURSE_URLS.each do |path|
  get path do
    message = Message.first({course_id: @id})

    not_found_if_nil! message

    ok(message)
  end
end

get MESSAGES_URL do
  ok(do_search(Message, params, {q: [:title], fields: [:course_id], }))
  puts 'Search message: ' << message.inspect
end

post MESSAGE_URL do
  discussion = Discussion.find_by_id @discussion_id
  not_found_if_nil! discussion

  message = Message.new @json
  message.discussion_id = discussion.id
  message.save

  created(message)
end

put MESSAGE_ID_URL do
  message = Message.find_by_id @id

  not_found_if_nil! message
  bad_request! if @json.has_key? :id || message[:id] != @json[:id]

  allowed_fields = %w(course_id title created_by)
  allowed_fields.each do |field|
    message[field] = @json[field] unless @json[field].nil?
  end

  puts 'Update message: ' << message.inspect

  ok message
end

delete MESSAGE_ID_URL do
  message = Message.find(@id)
  not_found_if_nil! message

  message.destroy
  ok JSON.parse message
end

# HACK: for debug
get '/messages/all' do
  ok Message.all
end
