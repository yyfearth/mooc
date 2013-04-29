class CategoryController < EntityController
  ID_URL = '/category/:id'
  COLLECTION_URL = '/categories'
  ALL_URL = COLLECTION_URL + '/all'

  #helpers do
  #end

  before do
    @entity_name = Category.name
  end

  before ID_URL do
    @id = params[:id]
  end

  # get a category by id (id)
  get ID_URL do
    category = Category.find_by_id @id
    entity_not_found? category
    ok category
  end

  # search categories
  get COLLECTION_URL do
    q = {}
    if params[:name] and !params[:name].blank?
      q[:name] = params[:name]
    elsif !params[:q].to_s.blank?
      q[:name] ={:$regex => params[:q]}
    end
    ok do_search Category.where(q), params
  end

  # create a new category
  post COLLECTION_URL do
    json = JSON.parse request.body.read
    begin
      created Category.create! json
    rescue MongoMapper::DocumentNotValid => e
      db_exception e
    end
  end

  # update a category
  put ID_URL do
    json = JSON.parse request.body.read
    id_not_matched? json
    begin
      ok Category.update @id, json
    rescue MongoMapper::DocumentNotValid => e
      db_exception e
    end
  end

  # delete a category by id (id)
  delete ID_URL do
    category = Category.find_by_id @id
    entity_not_found? category
    category.destroy
    ok "Category with id #{@id} deleted"
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
