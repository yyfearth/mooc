class CategoryController < EntityController
  ID_URL = '/category/:id'
  COLLECTION_URL = '/categories'
  ALL_URL = COLLECTION_URL + '/all'

  before ID_URL do
    @entity_name = Category.name
    @id = params[:id]
  end

  # get a category by id
  get ID_URL do
    category = Category.find_by_id @id
    not_found_if_nil category
    ok category
  end

  # search categories
  get COLLECTION_URL do
    # no limit by default
    params[:limit] = 0 if params[:limit].to_s.empty?
    ok do_search Category, params, fields: [:name], q: [:name]
  end

  # create a new category
  post COLLECTION_URL do
    json = JSON.parse request.body.read
    begin
      created Category.create! json
    rescue MongoMapper::DocumentNotValid => e
      invalid_entity e
    end
  end

  # update a category
  put ID_URL do
    json = JSON.parse request.body.read
    id_not_matched? json
    begin
      ok Category.update @id, json
    rescue MongoMapper::DocumentNotValid => e
      invalid_entity e
    end
  end

  # delete a category by id (id)
  delete ID_URL do
    category = Category.find_by_id @id
    not_found_if_nil category
    category.destroy
    ok "Category '#{@id}' deleted"
  end

  # FOR DEBUG ONLY

  # get all categories
  get ALL_URL do
    ok Category.all
  end

  # delete all categories
  delete ALL_URL do
    Category.destroy_all
    ok 'All categories cleared'
  end

end
