CATEGORY_ID_URL = '/category/:id'
CATEGORIES_URL = '/categories'

before CATEGORY_ID_URL do
  @entity_name = Category.name
  @id = params[:id]
end

# get a category by id
get CATEGORY_ID_URL do
  category = Category.find_by_id @id
  not_found_if_nil! category
  ok category
end

# search categories
get CATEGORIES_URL do
  # no limit by default
  params[:limit] = 0 if params[:limit].to_s.empty?
  ok do_search Category, params, fields: [:name], q: [:name]
end

# create a new category
post CATEGORIES_URL do
  begin
    created Category.create! @json
  rescue MongoMapper::DocumentNotValid => e
    invalid_entity! e
  end
end

# update a category
put CATEGORY_ID_URL do
  bad_request_if_id_not_match!
  begin
    ok Category.update @id, @json
  rescue MongoMapper::DocumentNotValid => e
    invalid_entity! e
  end
end

# delete a category by id (id)
delete CATEGORY_ID_URL do
  category = Category.find_by_id @id
  not_found_if_nil! category
  category.destroy
  ok "Category '#{@id}' deleted"
end

# FOR DEBUG ONLY
CATEGORIES_ALL_URL = CATEGORIES_URL + '/all'

# get all categories
get CATEGORIES_ALL_URL do
  ok Category.all
end

# delete all categories
delete CATEGORIES_ALL_URL do
  Category.destroy_all
  ok 'All categories cleared'
end
