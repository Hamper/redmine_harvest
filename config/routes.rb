Rails.application.routes.draw do |map|
  match 'projects/:project_id/harvest_reports' => 'harvest_reports#index'
end

