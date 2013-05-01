class CourseController < EntityController
  ID_URL = '/course/:id'
  COLLECTION_URL = '/courses'
  ALL_URL = COLLECTION_URL + '/all'

  before ID_URL do
    @entity_name = Category.name
    @id = params[:id]
  end

  # get a course by id (id)
  get ID_URL do
    course = Course.find_by_id @id
    entity_not_found? course
    ok course
  end

  # search courses
  get COLLECTION_URL do
    ok do_search Course, params,
                 fields: [:title, :category_id, :participant_email, :created_by],
                 q: [:title, :category_id, :description]
  end

  # create a new course
  post COLLECTION_URL do
    json = JSON.parse request.body.read
    begin
      created Course.create! json
    rescue MongoMapper::DocumentNotValid => e
      invalid_entity! e
    end
  end

  # update a course
  put ID_URL do
    json = JSON.parse request.body.read
    id_not_matched? json
    begin
      ok Course.update @id, json
    rescue MongoMapper::DocumentNotValid => e
      invalid_entity! e
    end
  end

  # delete a course by id (id)
  delete ID_URL do
    course = Course.find_by_id @id
    entity_not_found? course
    course.destroy
    ok "Course with ID '#{@id}' deleted"
  end

  # FOR DEBUG ONLY

  # get all courses
  get ALL_URL do
    ok Course.all
  end

  # delete all courses
  delete ALL_URL do
    Course.destroy_all
    ok 'All courses cleared'
  end

end
