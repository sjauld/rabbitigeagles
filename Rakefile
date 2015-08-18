# Rakefile

# Asset pipeline
require 'sinatra/asset_pipeline/task'
require './app'

Sinatra::AssetPipeline::Task.define!(App)

# Active record stuff
require 'sinatra/activerecord/rake'

# Send a mail
task 'thursday-update' do
  require './extensions/postmark'
  message = Mail.new do
    from    ENV['TIPPING_FROM_ADDRESS']
    to      ENV['TIPPING_MAILING_LIST']
    subject 'Weekly tipping reminder!'
    body    "Please ensure your tips are in by 5pm today!\n\nCurrent tips:-\n#{current_tipping_status}\n\n--\nTigersearabbit Tipping System"
    delivery_method Mail::Postmark, api_token: ENV['POSTMARK_API_TOKEN']
  end
  message.deliver
end
