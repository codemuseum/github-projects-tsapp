class <%= class_name %>Controller < ApplicationController

  # GET /<%= class_name.downcase %>.xml
  def index
    @page_objects = PageObject.find(:all, :conditions => { :urn => params[:from] })
    @<%= class_name.downcase %> = @page_objects.collect { |po| { :urn => po.urn } }
    
    respond_to do |format|
      format.xml  { render :xml => @<%= class_name.downcase %> }
    end
  end

end
