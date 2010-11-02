class SearchController < ApplicationController
  ENTRIES_PER_PAGE = 20

  def index
    @base_path = url_for(:action => "index")
    if params[:search_request].is_a?(Hash)
      redirect_to SearchRequest.path(:base_path => @base_path,
                                     :options => params[:search_request])
      return
    end

    @search_request = SearchRequest.new
    @search_request.parse(params[:search_request])
    @search_request_params = @search_request.to_hash

    if @search_request.valid?
      options = @search_request.attributes.merge(:page => params[:page])
    else
      @bad_request = @search_request
      @search_request = SearchRequest.new
      options = {}
    end

    search_result = Entry.search(options.merge(:per_page => ENTRIES_PER_PAGE))
    @entries = search_result[:entries]
    @raw_entries = search_result[:raw_entries]
    @drilldown_groups = search_result[:drilldown_groups]
    @topic_path_items = @search_request.topic_path_items(:base_path => @base_path)

    render :action => "bad_request", :status => 400 if @bad_request
  end

end
