class CategoryController < EntityController
  ID_URL = '/category/:id'
  COLLECTION_URL = '/categories'
  ALL_URL = COLLECTION_URL + '/all'

  helpers do
    def name_duplicated!(json)
      duplicated! 'name', json['name']
    end
  end

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
    name = nil
    name = {:$regex => params[:q]} unless params[:q].to_s.empty?
    name = params[:name] unless params[:name].to_s.empty?
    ok do_search Category.where(:name => name), params
  end

  # create a new category
  post COLLECTION_URL do
    json = JSON.parse request.body.read
    begin
      created Category.create! json
    rescue Mongo::OperationFailure => e
      puts e.inspect
      name_duplicated! json
    end
  end

  # update a category
  put ID_URL do
    json = JSON.parse request.body.read
    id_not_matched? json
    begin
      ok Category.update @id, json
    rescue Mongo::OperationFailure => e
      puts e.inspect
      name_duplicated! json
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
