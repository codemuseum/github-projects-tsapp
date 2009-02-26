# In your PageObject and Theme models (ActiveRecord), don't forget to include this!  
# In addition to providing some helpful methods, it also defines to_param,  
# find_by_param, and overrides to_xml to include HTML
#
# class PageObject < ActiveRecord::Base
#   include ThriveSmartObjectMethods
#   self.caching_default = :page_object_update [in :forever, :page_object_update, :any_page_object_update, 'data_update[datetimes]', :never, 'interval[5]'] - intervals reset on page updating
#
# You'll probably also want to override the method duplicate(urn)
# This method is supposed to "deep clone" the thrivesmart object, with a new urn.  
# It's used when site templates are copied, for example.
module ThriveSmartObjectMethods
  
  def self.included(klass)
    unless klass.included_modules.include?(InstanceMethods)
      klass.send :alias_method, :tsom_original_to_xml, :to_xml
      
      klass.extend ClassMethods
      klass.send :include, InstanceMethods
      
      klass.send :attr_accessor, :http_request # Stores the request within the page object for accessing
      klass.send :attr_accessor, :html
      klass.send :attr_accessor, :alml
      klass.send :attr_reader, :javascripts
      klass.send :attr_reader, :stylesheets
      klass.send :attr_accessor, :site_uid # Stores the request header Site-UID
      klass.send :attr_protected, :http_request, :html, :alml, :javascripts, :stylesheets, :site_uid, :caching, :caching_scope
      klass.send :validates_presence_of, :urn
      klass.send :validates_uniqueness_of, :urn, :case_sensitive => false
    end
  end
  
  module ClassMethods
    def find_by_param(param)
      self.find_by_urn(param)
    end
    
    # Similar to find_by_param but sets the variables from the request 
    def find_from_request(param, request)
      returning self.find_by_param(param) do |po|
        po.read_request(request) if po && request
      end
    end
    
    def caching_default
      @caching_default || ''
    end
    
    def caching_default=(cd)
      @caching_default = cd
    end
    
    
    def caching_scope_default
      @caching_scope_default || ''
    end
    
    def caching_scope_default=(csd)
      @caching_scope_default = csd
    end
  end
  
  module InstanceMethods
  
    # Override me!  This should return a new_record? that has duplicate content.  Used in the 'clone' controller action.
    def duplicate(new_urn, attr_hash = {})
      returning clone do |tso|
        tso.site_uid = self.site_uid
        tso.attributes = attr_hash
        tso.urn = new_urn
      end
    end
  
    def javascripts=(sources_array)
      @javascripts ||= []
      @javascripts += sources_array
    end

    def stylesheets=(sources_array)
      @stylesheets ||= []
      @stylesheets += sources_array
    end
  
    def caching= (c)
      @caching = c
    end
  
    def caching
      @caching ? @caching : self.class.caching_default
    end

    def caching_scope= (cs)
      @caching_scope = cs
    end

    def caching_scope
      @caching_scope ? @caching_scope : self.class.caching_scope_default
    end

    def read_request(request)
      self.http_request = request
      self.site_uid = request.headers[ThriveSmart::Constants.ts_site_headers_key]
    end

    def to_param
      urn
    end

    def page_url
      self.http_request.headers[ThriveSmart::Constants.ts_page_url_headers_key]
    end

    def page_query_parameters
      return @page_query_parameters if @page_query_parameters
      
      query_string = self.http_request.headers[ThriveSmart::Constants.ts_page_query_string_key]
      @page_query_parameters = {}

      (query_string.blank? ? '' : query_string).split('&').collect do |chunk|
        next if chunk.empty?
        key, value = chunk.split('=', 2)
        next if key.empty?
        @page_query_parameters[CGI.unescape(key).to_sym] = CGI.unescape(value)
      end
      @page_query_parameters
    end
    
    def site
      ThriveSmartObjectMethods::Data.prepare(site_uid.to_s, urn, http_request.headers[ThriveSmart::Constants.ts_user_session_headers_key])
      ThriveSmartObjectMethods::Data
    end
  
    def to_xml(options = {})
      tsom_original_to_xml({:methods => [:html, :alml, :caching, :caching_scope]}.merge(options)) do |xml|
        unless errors.nil? || errors.size == 0
          xml.errors do errors.full_messages.each { |msg| xml.error msg } end
        end
        unless javascripts.nil? || javascripts.size == 0
          # FIXME - this is a stop-gap measure for the period where rails can't handle simple arrays of strings
          xml.javascripts :type => :array do javascripts.each { |src| xml.string do xml.string src end } end
        end
        unless stylesheets.nil? || stylesheets.size == 0
          # FIXME - this is a stop-gap measure for the period where rails can't handle simple arrays of strings
          xml.stylesheets :type => :array do stylesheets.each { |src| xml.string do xml.string src end } end
        end
      end
    end
  end

  class Data < ActiveResource::Base
    self.site = ThriveSmart::Constants.ts_platform_host
    self.collection_name = 'data' # FIXME when rails knows that 2 pieces of data is still "data" and not "datas"

    def self.prepare(site_uid, page_object_urn, user_session_id)
      headers[ThriveSmart::Constants.ts_site_headers_key] = site_uid
      headers[ThriveSmart::Constants.ts_user_session_headers_key] = user_session_id
      headers[ThriveSmart::Constants.ts_page_object_urn_headers_key] = page_object_urn
    end

    def self.find_data(data_path, options = {})
      find(:all, :params => {:data_path => data_path, :options => options})
    end
  end
end