class Controller < Sinatra::Base
  helpers ControllerHelper

  before do
    content_type :json
  end

  error(404) do
    err 404, 'NOT_FOUND', 'Not found'
  end

end
