COURSE_URL = '/course'
COURSES_URL = '/courses'
COURSE_ID_URL = "#{COURSE_URL}/:id"

helpers do
  def enroll
    course = Course.find_by_id @id
    not_found_if_nil! course
    begin
      course.push_uniq participants: @json
      ok "User #{@json['email']} enrolled course #{@id}"
    rescue MongoMapper::DocumentNotValid => e
      invalid_entity! e
    end
  end

  def drop(email)
    course = Course.find_by_id @id
    not_found_if_nil! course
    participant = course.participants.detect { |p| p.email == email }
    begin
      participant.status = :DROPPED
      ok "User #{email} dropped course #{@id}"
    rescue MongoMapper::DocumentNotValid => e
      invalid_entity! e
    end
  end
end

before "#{COURSE_ID_URL}*" do
  @entity_name = Category.name
  @id = params[:id] unless params[:id] =~ /^(?:enroll|drop)$/
end

# get all courses
get %r{/courses?/(?:list|all)} do
  ok Course.all
end

# get a course by id
get COURSE_ID_URL do
  course = Course.find_by_id @id
  not_found_if_nil! course
  ok course
end

# get category of a course
get "#{COURSE_ID_URL}/category" do
  course = Course.find_by_id @id
  not_found_if_nil! course
  redirect to('/category/' + course.category_id), 301
end

# get category of a course
get "#{COURSE_ID_URL}/participants" do
  show_dropped = is_param_on? :with_dropped
  course = Course.find_by_id @id
  not_found_if_nil! course
  participants = {} # hash index
  course.participants.each do |p|
    if show_dropped || p.status != :DROPPED
      participants[p.email] = p.serializable_hash
    end
  end
  users = User.find participants.keys
  participants = users.map do |u|
    u.serializable_hash.merge participants[u.email]
  end
  ok participants
end

post "#{COURSE_ID_URL}/participants" do
  enroll
end

put "#{COURSE_ID_URL}/participant/:email" do
  @json ||= {email: params[:email]}
  enroll
end

delete "#{COURSE_ID_URL}/participant/:email" do
  drop params[:email]
end

put "#{COURSE_URL}/enroll" do
  @id = params[:courseid] || params[:course_id]
  @json = {email: params[:email]}
  enroll
end

put "#{COURSE_URL}/drop" do
  @id = params[:courseid] || params[:course_id]
  drop params[:email]
end

# search courses
get COURSES_URL do
  p_email = params[:participant_email]
  params[:'participants.email'] = p_email unless p_email.to_s.empty?
  ok do_search Course, params,
               fields: [:title, :category_id, :'participants.email', :created_by],
               q: [:title, :category_id, :description]
end

# create a new course
post %r{/courses?} do
  # compatibility
  @json['category_id'] = @json['category'] if @json['category_id'].nil? and @json['category']
  @json['created_by'] = @json['instructor'][0]['email'] if @json['created_by'].nil? and @json['instructor'].is_a? Array
  # do create
  begin
    created Course.create! @json
  rescue MongoMapper::DocumentNotValid => e
    invalid_entity! e
  end
end

# update a course
put COURSE_ID_URL do
  pass unless @id && @json
  bad_request_if_id_not_match!
  begin
    ok Course.update @id, @json
  rescue MongoMapper::DocumentNotValid => e
    invalid_entity! e
  end
end

# delete a course by id (id)
delete COURSE_ID_URL do
  course = Course.find_by_id @id
  not_found_if_nil! course
  course.destroy
  ok "Course '#{@id}' deleted"
end


# FOR DEBUG ONLY
# delete all courses
#delete COURSES_URL do
#  Course.destroy_all
#  ok 'All courses cleared'
#end
