require 'action_view'
require File.join(File.dirname(__FILE__), 'lib', 'tsapp_rails')

ActionView::Base.send(:include, ThriveSmart::Helpers::FormHelper)
ActionView::Base.send(:include, ThriveSmart::Helpers::ViewHelper)

Mime::Type.register_alias "application/json", :tson