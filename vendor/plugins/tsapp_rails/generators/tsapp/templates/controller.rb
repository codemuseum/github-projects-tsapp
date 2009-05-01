class <%= controller_class_name %>Controller < ApplicationController
  include PageObjectsControllerHelper
  before_filter :find_<%= file_name %>, :only => [ :show, :edit, :update, :destroy ]
  before_filter :prepare_<%= file_name %>_for_clone, :only => [ :duplicate ]
  
  # GET /<%= table_name %>
  # GET /<%= table_name %>.xml
  # GET /<%= table_name %>.tson
  def index
    @<%= table_name %> = <%= class_name %>.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @<%= table_name %> }
      format.tson { render :json => @<%= table_name %> }
    end
  end

  # GET /<%= table_name %>/1
  # GET /<%= table_name %>/1.xml
  # GET /<%= table_name %>/1.tson
  def show
    render_to_page_object

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @<%= file_name %> }
      format.tson { render :json => @<%= file_name %> }
    end
  end

  # GET /<%= table_name %>/new
  # GET /<%= table_name %>/new.xml
  # GET /<%= table_name %>/new.tson
  def new
    @<%= file_name %> = <%= class_name %>.new(params[:<%= file_name %>])
    render_to_page_object

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @<%= file_name %> }
      format.tson { render :json => @<%= file_name %> }
    end
  end

  # GET /<%= table_name %>/1/edit
  # GET /<%= table_name %>/1/edit.xml
  # GET /<%= table_name %>/1/edit.tson
  def edit
    render_to_page_object
    
    respond_to do |format|
      format.html # edit.html.erb
      format.xml  { render :xml => @<%= file_name %> }
      format.tson { render :json => @<%= file_name %> }
    end
  end

  # POST /<%= table_name %>
  # POST /<%= table_name %>.xml
  # POST /<%= table_name %>.tson
  def create
    @<%= file_name %> = <%= class_name %>.new(params[:<%= file_name %>])

    respond_to do |format|
      if @<%= file_name %>.save
        flash[:notice] = '<%= class_name %> was successfully created.'
        format.html { redirect_to(@<%= file_name %>) }
        format.xml  { render :xml => @<%= file_name %>, :status => :created, :location => @<%= file_name %> }
        format.tson { render :json => @<%= file_name %>, :status => :created, :location => @<%= file_name %> }
      else
        render_to_page_object
        format.html { render :action => "new" }
        format.xml  { render :xml => @<%= file_name %>, :status => :unprocessable_entity }
        format.tson { render :json => @<%= file_name %>, :status => :unprocessable_entity }
      end
    end
  end
  
  # POST /<%= table_name %>/duplicate?source=:urn
  # POST /<%= table_name %>/duplicate.xml?source=:urn
  # POST /<%= table_name %>/duplicate.tson?source=:urn
  def duplicate

    respond_to do |format|
      if @<%= file_name %>.save
        flash[:notice] = '<%= class_name %> was successfully created.'
        format.html { redirect_to(@<%= file_name %>) }
        format.xml  { render :xml => @<%= file_name %>, :status => :created, :location => @<%= file_name %> }
        format.tson { render :json => @<%= file_name %>, :status => :created, :location => @<%= file_name %> }
      else
        render_to_page_object
        format.html { render :action => "new" }
        format.xml  { render :xml => @<%= file_name %>, :status => :unprocessable_entity }
        format.tson { render :json => @<%= file_name %>, :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /<%= table_name %>/1
  # PUT /<%= table_name %>/1.xml
  # PUT /<%= table_name %>/1.tson
  def update

    respond_to do |format|
      if @<%= file_name %>.update_attributes(params[:<%= file_name %>])
        flash[:notice] = '<%= class_name %> was successfully updated.'
        format.html { redirect_to(@<%= file_name %>) }
        format.xml  { head :ok }
        format.tson { head :ok }
      else
        render_to_page_object
        format.html { render :action => "edit" }
        format.xml  { render :xml => @<%= file_name %>, :status => :unprocessable_entity }
        format.tson { render :json => @<%= file_name %>, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /<%= table_name %>/1
  # DELETE /<%= table_name %>/1.xml
  # DELETE /<%= table_name %>/1.tson
  def destroy
    @<%= file_name %>.destroy

    respond_to do |format|
      format.html { redirect_to(<%= table_name %>_url) }
      format.xml  { head :ok }
      format.tson { head :ok }
    end
  end
end
