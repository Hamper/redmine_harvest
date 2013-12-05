Rails.application.routes.draw do
    match 'projects/:project_id/harvest_reports' => 'harvest_reports#index'
end

