DISCUSSION_URL = '/discussion'
DISCUSSIONS_URL = '/discussions'
DISCUSSION_ID_URL = "#{DISCUSSION_URL}/:id"
DISCUSSION_COURSE_URLS = %w(/discussion/course/:id /course/:id/discussion)

before "#{DISCUSSION_URL}*" do
  @entity_name = Discussion.name
end

DISCUSSION_COURSE_URLS.concat([DISCUSSION_ID_URL]).each do |url|
  before url do
    @id = params[:id]
    @entity_name = Discussion.name
    puts 'id = ' << @id.to_s
  end
end

get DISCUSSION_ID_URL do
  discussion = Discussion.find_by_id @id

  not_found_if_nil!(discussion)

  ok(discussion)
end

DISCUSSION_COURSE_URLS.each do |path|
  get path do
    discussion = Discussion.first({course_id: @id})

    not_found_if_nil! discussion

    ok(discussion)
  end
end

get DISCUSSIONS_URL do
  puts "Search discussion"
  ok(do_search(Discussion, params, {q: [:title], fields: [:course_id], }))
end

post %r{/discussions?} do
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

  discussion.destroy
  ok JSON.parse discussion
end

# HACK: for debug
get '/discussions/all' do
  ok Discussion.all
end
