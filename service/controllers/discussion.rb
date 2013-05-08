DISCUSSION_URL = %r{^/discussions?$}
DISCUSSION_ID_URL = %r{^/discussions?/(?<id>[\w\d]{24})$}

before '/discussions?/*' do
  @entity_name = Discussion.name
end

[DISCUSSION_ID_URL].each do |url|
  before url do
    @id = params[:id]
    @entity_name = Discussion.name

    #discussion = Discussion.first({course_id: @id})
    #not_found_if_nil! discussion
  end
end

get DISCUSSION_URL do
  ok do_search Discussion, params, {q: [:title], fields: [:course_id], }
end

get DISCUSSION_ID_URL do
  discussion = Discussion.find_by_id @id

  not_found_if_nil! discussion

  ok(discussion)
end

post DISCUSSION_URL do
  discussion = Discussion.create @json
  puts 'Create discussion: ' << discussion.inspect
  created(discussion)
end

put DISCUSSION_ID_URL do
  discussion = Discussion.find_by_id @id

  not_found_if_nil! discussion
  bad_request! if @json.has_key? :id || discussion[:id] != @json[:id]

  allowed_fields = %w(course_id title created_by)
  allowed_fields.each do |field|
    discussion[field] = @json[field] unless @json[field].nil?
  end

  puts 'Update discussion: ' << discussion.inspect

  ok discussion
end

delete DISCUSSION_ID_URL do
  discussion = Discussion.find(@id)
  not_found_if_nil! discussion

  ok Discussion.destroy @id
end

# HACK: for debug
get '/discussions/all' do
  ok Discussion.all
end
