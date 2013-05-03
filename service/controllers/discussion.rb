require '../models/discussion'

class DiscussionController < EntityController
  SINGLE_ID_URL = '/discussion/:id'
  SINGLE_URL = '/discussion'
  MULTIPLE_URL = '/discussions'
  GET_BY_COURSE_URLS = %w(/discussion/course/:id /course/:id/discussion)
  ADD_DISCUSSION_URL = '/discussion'

  @entity = Discussion.name
  @entity_name = Discussion.name

  # Store the request JSON globally.
  before '*' do
    begin
      request_content = request.body.read
      puts request_content.empty? ? 'No content' : 'Request content = ' << request_content
      @json = JSON.parse(request_content) unless request_content.to_s.empty?
    rescue JSON::ParserError => e
      warn e.backtrace[0]
      warn e.inspect
      err 400, 'BAD_REQUEST', 'Cannot parse the request data' if request_content
    end
  end

  # Store the id globally.
  [GET_BY_COURSE_URLS, SINGLE_ID_URL].each do |url|
    before url do
      @id = params[:id]
      puts 'id = ' << @id.to_s
    end
  end

  get SINGLE_ID_URL do
    discussion = Discussion.find_by_id(@id)

    if discussion.nil?
      id_not_found(Discussion, @id)
    else
      ok(discussion)
    end
  end

  GET_BY_COURSE_URLS.each do |path|
    get path do
      discussion = Discussion.first({course_id: @id})

      id_not_found(Course, @id) if discussion.nil?

      ok(discussion)
    end
  end

  get MULTIPLE_URL do
    ok(do_search(Discussion, params, {q: [:title], fields: [:course_id], }))
    puts 'Search discussion: ' << discussion.inspect
  end

  post SINGLE_URL do
    bad_request('The request data does not match expected format') unless %w(title created_by).all? { |k| @json.has_key?(k) }
    discussion = Discussion.create(@json)
    puts 'Create discussion: ' << discussion.inspect
    created(discussion)
  end

  put SINGLE_ID_URL do
    discussion = Discussion.find_by_id(@id)

    id_not_found(Discussion, @id) if discussion.nil?

    @json.each { |k| discussion[k] = @json[k] }

    discussion.save

    puts 'Update discussion: ' << discussion.inspect

    ok(discussion)
  end

  delete SINGLE_ID_URL do
    discussion = Discussion.find(@id)
    not_found_if_nil(discussion)

    discussion.destroy
    ok('Delete discussion ' << @id)
  end

  # HACK: for debug
  get '/discussions/all' do
    ok(Discussion.all)
  end
end
