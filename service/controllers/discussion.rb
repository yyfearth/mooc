class DiscussionController < EntityController
  GET_URL = '/discussion/:id'
  GET_BY_COURSE_URL = '/discussion/course/:id'
  ADD_DISCUSSION_URL = '/discussion'

  get GET_URL do
    'GET_URL'
  end

  get GET_BY_COURSE_URL do
    'GET_BY_COURSE_URL'
  end
end