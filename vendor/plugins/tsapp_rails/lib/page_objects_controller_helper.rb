# In your PageObjectsController, don't forget to include this!  
# In addition to providing some helpful methods, it also defines update_valid and create_valid,
# which are not the usual restful actions.  They correspond to validation calls before saves are sent.
#
# class PageObjectsController < ApplicationController
#   include ThriveSmart::PageObjectsControllerHelper
#
# You probably also want to include a line to call the find_page_object method, like:
#    before_filter :find_page_object, :only => [ :show, :edit, :update, :destroy ]
#    before_filter :prepare_page_object_for_clone, :only => [ :duplicate ]
# 
# Before any render call, be sure to call the method render_to_page_object, e.g.
#
# def show
#   render_to_page_object 
module PageObjectsControllerHelper
  
  def self.included(klass)
    unless klass.included_modules.include?(InstanceMethods)
      klass.send :include, InstanceMethods
      klass.send :before_filter, :verify_request_signature
      klass.send :before_filter, :find_page_object_for_custom_methods, :only => [ :update_valid ]
    end
  end
  
  module InstanceMethods
    # PUT /page_objects/:urn/update_valid
    def update_valid
      @page_object.attributes = params[:page_object]
      validate_and_respond
    end

    # POST /page_objects/:urn/create_valid
    def create_valid
      @page_object = PageObject.new(params[:page_object])
      validate_and_respond
    end
  
    def duplicate_valid
      prepare_page_object_for_clone  
      validate_and_respond
    end
    
  
    protected
  
  
      def verify_request_signature
        # Build sig params first, then verify signature digest
        sig_params = {}
        request.headers[ThriveSmart::Constants.ts_signature_headers_key].split('&').each { |pair| k,v = pair.split('='); sig_params[k] = v ? CGI::unescape(v) : v }
        
        raw = sig_params.reject { |k,v| k.to_s[0,7] != 'ts_sig_' }.map{ |*args| args.join('=') }.sort.join('&')
        actual_sig = Digest::MD5.hexdigest([raw, ThriveSmart::Constants.config['secret_key']].join)
        raise ThriveSmart::IncorrectSignature if actual_sig != sig_params['ts_sig']
        raise ThriveSmart::SignatureTooOld if sig_params['ts_sig_time'] && Time.at(sig_params['ts_sig_time'].to_f) < ThriveSmart::Constants.ts_max_signature_age.ago
        true
      end
  
      def validate_and_respond
        valid = @page_object.valid?
        render_to_page_object # must come after validation

        respond_to do |format|
          format.xml  { render :xml => @page_object, :status => (valid ? :ok : :unprocessable_entity) }
        end
      end

      def prepare_page_object_for_clone
        @page_object = PageObject.find_from_request(params[:source], request).duplicate(params[:page_object].delete(:urn), params[:page_object])
      end
      
      # So the controller can create it's own before_filter for calling find_page_object without distrupting this controller's
      def find_page_object_for_custom_methods
        find_page_object
      end
      
      def find_page_object
        @page_object = PageObject.find_from_request(params[:id], request)
        raise ActiveRecord::RecordNotFound unless @page_object
        @page_object
      end

      def render_to_page_object(action_str = nil)
        action_str ||= case action_name.to_s
        when 'update_valid'
          'edit'
        when 'create_valid'
          'new'
        when 'update'
          'edit'
        when 'create'
          'new'
        else
          action_name
        end
        @page_object.html = render_to_string :action => "#{action_str}.html.erb"
      end
  end
end