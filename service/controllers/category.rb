class CategoryController < EntityController
  ID_URL = '/category/:id'
  COLLECTION_URL = '/categories'
  ALL_URL = COLLECTION_URL + '/all'

  helpers do
    def invalid_json?(json)
      no_id_in_json? json
    end
  end

  # get a category by id (id)
  get ID_URL do
    id = params[:id]
    category = Category.find_by_id id
    entity_not_found? Category, id, category,
    ok category
  end

  # search categories
  get COLLECTION_URL do
    ok do_search Category, params
  end

  # create a new category
  post ID_URL do
    json = JSON.parse request.body.read
    invalid_json? json
    created Category.create! json
  end

  # update a category
  put ID_URL do
    json = JSON.parse request.body.read
    invalid_json? json
    id_not_matched? params, json
    id = params[:id]
    ok Category.update id, json
  end

  # delete a category by id (id)
  delete ID_URL do
    id = params[:id]
    category = Category.find_by_id id
    entity_not_found? id, category
    category.destroy
    ok "Category with id #{id} deleted"
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

  run!

end
