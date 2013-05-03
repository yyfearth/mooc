ANNOUNCEMENT_ID_URL = '/announcement/:id'
ANNOUNCEMENTS_URL = '/announcements'

helpers do
  def search_announcements!
    # no limit by default
    params[:limit] = 0 if params[:limit].to_s.empty?
    ok do_search Announcement, params, fields: [:title], q: [:title, :content]
  end
end

before "#{ANNOUNCEMENT_ID_URL}*" do
  @entity_name = Announcement.name
  @id = params[:id]
end

# get a announcement by id
get ANNOUNCEMENT_ID_URL do
  announcement = Announcement.find_by_id @id
  not_found_if_nil! announcement
  ok announcement
end

# get course of a announcement
get "#{ANNOUNCEMENT_ID_URL}/course" do
  announcement = Announcement.find_by_id @id
  not_found_if_nil! announcement
  if announcement.course_id
    redirect to('/course/' + announcement.course_id), 301
  else
    not_found! 'ANNOUNCEMENT_WITHOUT_COURSE', 'The announcement is not associated with a course'
  end
end

# search announcements
get ANNOUNCEMENTS_URL do
  search_announcements!
end

# search announcements by course
get "#{ANNOUNCEMENTS_URL}/course/:course_id" do
  params[:course_id] = params[:course_id]
  search_announcements!
end
get "/course/:course_id#{ANNOUNCEMENTS_URL}" do
  params[:course_id] = params[:course_id]
  search_announcements!
end

# create a new announcement
post ANNOUNCEMENTS_URL do
  begin
    created Announcement.create! @json
  rescue MongoMapper::DocumentNotValid => e
    invalid_entity! e
  end
end

# update a announcement
put ANNOUNCEMENT_ID_URL do
  bad_request_if_id_not_match!
  begin
    ok Announcement.update @id, @json
  rescue MongoMapper::DocumentNotValid => e
    invalid_entity! e
  end
end

# delete a announcement by id (id)
delete ANNOUNCEMENT_ID_URL do
  announcement = Announcement.find_by_id @id
  not_found_if_nil! announcement
  announcement.destroy
  ok "Announcement '#{@id}' deleted"
end

# FOR DEBUG ONLY
ANNOUNCEMENTS_ALL_URL = ANNOUNCEMENTS_URL + '/all'

# get all announcements
get ANNOUNCEMENTS_ALL_URL do
  ok Announcement.all
end

# delete all announcements
delete ANNOUNCEMENTS_ALL_URL do
  Announcement.destroy_all
  ok 'All announcements cleared'
end
