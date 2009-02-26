class PageObject < ActiveRecord::Base
  include ThriveSmartObjectMethods
  
  # Reloads every 3 hours
  self.caching_default = 'interval[180]' 
  #[in :forever, :page_object_update, :any_page_object_update, 'data_update[datetimes]', :never, 'interval[5]']

  def github
    self.account.blank? ? nil : GitHub::API.user(self.account)
  end
  
  def repositories
    github ? [] : github.repositories
  end
end
