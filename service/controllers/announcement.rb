class AnnouncementController < EntityController
  ID_URL = '/announcement/:id'
  COLLECTION_URL = '/announcements'
  ALL_URL = COLLECTION_URL + '/all'

  helpers do
    def search_announcements!
      # no limit by default
      params[:limit] = 0 if params[:limit].to_s.empty?
      ok do_search Announcement, params, fields: [:title], q: [:title, :content]
    end
  end

  before "#{ID_URL}*" do
    @entity_name = Announcement.name
    @id = params[:id]
  end

  # get a announcement by id
  get ID_URL do
    announcement = Announcement.find_by_id @id
    entity_not_found? announcement
    ok announcement
  end

  # get course of a announcement
  get "#{ID_URL}/course" do
    announcement = Announcement.find_by_id @id
    entity_not_found? announcement
    if announcement.course_id
      redirect to('/course/' + announcement.course_id), 301
    else
      not_found 'ANNOUNCEMENT_WITHOUT_COURSE', 'The announcement is not associated with a course'
    end
  end

  # search announcements
  get COLLECTION_URL do
    search_announcements!
  end

  # search announcements by course
  get "#{COLLECTION_URL}/course/:course_id" do
    params[:course_id] = params[:course_id]
    search_announcements!
  end
  get "/course/:course_id#{COLLECTION_URL}" do
    params[:course_id] = params[:course_id]
    search_announcements!
  end

  # create a new announcement
  post COLLECTION_URL do
    json = JSON.parse request.body.read
    begin
      created Announcement.create! json
    rescue MongoMapper::DocumentNotValid => e
      invalid_entity! e
    end
  end

  # update a announcement
  put ID_URL do
    json = JSON.parse request.body.read
    id_not_matched? json
    begin
      ok Announcement.update @id, json
    rescue MongoMapper::DocumentNotValid => e
      invalid_entity! e
    end
  end

  # delete a announcement by id (id)
  delete ID_URL do
    announcement = Announcement.find_by_id @id
    entity_not_found? announcement
    announcement.destroy
    ok "Announcement '#{@id}' deleted"
  end

  # FOR DEBUG ONLY

  # get all announcements
  get ALL_URL do
    ok Announcement.all
  end

  # delete all announcements
  delete ALL_URL do
    Announcement.destroy_all
    ok 'All announcements cleared'
  end

end
