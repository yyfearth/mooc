class SearchParams
  attr_reader :offset, :limit, :order_by, :where

  def initialize(params)
    @offset = params[:offset] || 0
    @limit = params[:limit] || 20
    @order_by = params[:order_by] || :created_by.desc
    created_from = params[:created_from]
    created_to = params[:created_to]
    updated_from = params[:updated_from]
    updated_to = params[:updated_to]
    @where = {}
    @where[:created_at.gte] = Time.parse(created_from) unless created_from.to_s.empty?
    @where[:created_at.lte] = Time.parse(created_to) unless created_to.to_s.empty?
    @where[:updated_at.gte] = Time.parse(updated_from) unless updated_from.to_s.empty?
    @where[:updated_at.lte] = Time.parse(updated_to) unless updated_to.to_s.empty?
  end
end
