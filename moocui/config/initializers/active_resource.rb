class ActiveResource::Base
  self.site = '127.0.0.1:9494' # 'http://mooc-api.cloudfoundry.com/'
  #self.element_name = '' #if get|put|delete, then element_path
  #self.collection_name = '' #if post, then collection_path

  class << self
    def element_path(id, prefix_options = {}, query_options = nil)
      prefix_options, query_options = split_options(prefix_options) if query_options.nil?
      "#{prefix(prefix_options)}#{element_name}/#{id}#{query_string(query_options)}"
    end

    def collection_path(prefix_options = {}, query_options = nil)
      prefix_options, query_options = split_options(prefix_options) if query_options.nil?
      "#{prefix(prefix_options)}#{collection_name}#{query_string(query_options)}"
    end
  end

  def to_json(options={})
    self.attributes.to_json(options)
  end
end
