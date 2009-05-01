class <%= class_name %>Controller < ApplicationController

  # GET /<%= class_name.downcase %>.tson
  def index
    @page_objects = PageObject.find(:all, :conditions => { :urn => params[:from] })
    @<%= class_name.downcase %> = @page_objects.collect { |po| { :urn => po.urn } }
    
    respond_to do |format|
      format.tson  { render :json => @<%= class_name.downcase %> }
    end
  end

end
