COURSE_ID_URL = '/course/:id'
COURSES_URL = '/courses'

before "#{COURSE_ID_URL}*" do
  @entity_name = Category.name
  @id = params[:id]
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
  begin
    created Course.create! @json
  rescue MongoMapper::DocumentNotValid => e
    invalid_entity! e
  end
end

# update a course
put COURSE_ID_URL do
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
