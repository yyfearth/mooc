MESSAGE_URL = %r{^/discussions?/(?<discussion_id>[\w\d]{24})/messages?$}
MESSAGE_ID_URL = %r{^/discussions?/(?<discussion_id>[\w\d]{24})/messages?/(?<id>[\w\d]{24})$}

before "#{MESSAGE_URL}*" do
  @entity_name = Message.name
end

[MESSAGE_URL, MESSAGE_ID_URL].each do |url|
  before url do
    @id = params[:id]
    @discussion_id = params[:discussion_id]
    @entity_name = Message.name
    puts 'id = ' << @id.to_s
  end
end

get MESSAGE_ID_URL do
  discussion = Discussion.find_by_id @discussion_id
  not_found_if_nil! discussion

  message = Message.find_by_id @id
  not_found_if_nil! message

  ok message
end

get %r{/discussions?/(?<discussion_id>.+)/messages?} do
  puts 'Search message'
  ok do_search Message, params, {q: [:title], fields: [:course_id], }
end

post MESSAGE_URL do
  discussion = Discussion.find_by_id @discussion_id
  not_found_if_nil! discussion, @discussion_id

  message = Message.new @json
  message.discussion_id = discussion.id
  message.save

  created message
end

put MESSAGE_ID_URL do
  discussion = Discussion.find_by_id @discussion_id
  not_found_if_nil! discussion

  message = Message.find_by_id @id
  not_found_if_nil! message

  [:id, :discussion_id].each { |field|
    bad_request! if @json.has_key? field || message[field] != @json[field]
  }

  message = Message.update @id, @json
  puts 'Update message: ' << message.inspect
  ok message
end

delete MESSAGE_ID_URL do
  discussion = Discussion.find_by_id @discussion_id
  not_found_if_nil! discussion

  message = Message.find_by_id @id
  not_found_if_nil! message

  Message.destroy @id
  ok message
end

get %r{/messages?/(?:list|all)} do
  puts 'Get all messages'
  ok Message.all
end
