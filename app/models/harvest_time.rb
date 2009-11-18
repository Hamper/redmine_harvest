class HarvestTime < ActiveRecord::Base
  
  belongs_to :issue
  belongs_to :project
  belongs_to :user
  
  # Find the Harvest Project ID for a Redmine project. 
  def self.project_id(project)
    # Find the custom value of type "harvest_project_id"
    custom_value = project.custom_values.detect {|v| v.custom_field_id == Setting.plugin_redmine_harvest['harvest_project_id'].to_i}
    harvest_project_id = custom_value.value.to_i if custom_value
  end
  
  # Find the Harvest User ID for a Redmine user. 
  def self.user_id(user)
    custom_value = user.custom_values.detect {|v| v.custom_field_id == Setting.plugin_redmine_harvest['harvest_user_id'].to_i}
    harvest_user_id = custom_value.value.to_i if custom_value
  end
  
  def self.import_time(project)
    harvest_project_id = self.project_id(project)
    #harvest_project_id = 408960
    # From date of last job for project minus 1 week;  Default to 1 year ago.
    from_date = HarvestTime.maximum(:created_at, :conditions=>{:project_id => project.id})
    from_date = from_date.nil? ? 1.year.ago : from_date - 1.week 
    
    to_date = Time.now
    
    harvest_user_custom_field_id = Setting.plugin_redmine_harvest['harvest_user_id']
    
    Harvest.report.project_entries(harvest_project_id, from_date, to_date).each do |entry|
      entry.project_id = project.id
      
      # Find the Redmine user id through the CustomValue data
      user_custom_value = CustomValue.find_by_value_and_custom_field_id(entry.user_id, harvest_user_custom_field_id)
      entry.user_id = user_custom_value ? user_custom_value.customized.id : nil

      entry.issue_id = entry.notes[/#\D*(\d+)/, 1] if entry.notes

      ht = HarvestTime.find_or_create_by_id(entry.id)
      
      ht.update_attributes(entry.to_hash)
    end
    
    
  end
end
