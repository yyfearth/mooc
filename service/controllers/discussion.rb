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
  discussion = Discussion.find_by_id(@id)

  not_found_if_nil!(discussion)

  ok(discussion)
end

DISCUSSION_COURSE_URLS.each do |path|
  get path do
    discussion = Discussion.first({course_id: @id})

    not_found_if_nil!(discussion)

    ok(discussion)
  end
end

get DISCUSSIONS_URL do
  ok(do_search(Discussion, params, {q: [:title], fields: [:course_id], }))
  puts 'Search discussion: ' << discussion.inspect
end

post DISCUSSION_URL do
  discussion = Discussion.create(@json)
  puts 'Create discussion: ' << discussion.inspect
  created(discussion)
end

put DISCUSSION_ID_URL do
  discussion = Discussion.find_by_id(@id)

  not_found_if_nil!(discussion)

  @json.each { |k| discussion[k] = @json[k] }

  discussion.save

  puts 'Update discussion: ' << discussion.inspect

  ok(discussion)
end

delete DISCUSSION_ID_URL do
  discussion = Discussion.find(@id)
  not_found_if_nil!(discussion)

  discussion.destroy
  ok('Delete discussion ' << @id)
end

# HACK: for debug
get '/discussions/all' do
  ok(Discussion.all)
end
