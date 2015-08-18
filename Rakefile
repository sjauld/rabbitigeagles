# Rakefile

# Asset pipeline
require 'sinatra/asset_pipeline/task'
require './app'

Sinatra::AssetPipeline::Task.define!(App)

# Active record stuff
require 'sinatra/activerecord/rake'

# Send a mail
task 'thursday-update' do
  if Time.now.thursday?
    email_the_bastards("Week #{current_week} tipping reminder!","Please ensure your tips are in by 5pm today!")
  else
    puts "It's not Thursday, sunshine"
  end
end
