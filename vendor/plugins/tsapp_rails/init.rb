require 'action_view'
require File.join(File.dirname(__FILE__), 'lib', 'tsapp_rails')

# FIXME - why doesn't the first line work, when the second, does?
# ActionView::Helpers::FormHelper.send(:include, ThriveSmart::Helpers::FormHelper)
ActionView::Base.send(:include, ThriveSmart::Helpers::FormHelper)
ActionView::Base.send(:include, ThriveSmart::Helpers::ViewHelper)