
get '/' do
  values = KeyValue.all
  values.to_json
end

post '/' do
  KeyValue.create!(params)
  redirect '/'
end
