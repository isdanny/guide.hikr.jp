# myapp.rb
require 'sinatra'

set :public_folder, "_site"
set :static, true

get "/" do
  File.read(File.join("_site","index.html"))
end

get '/c/:page' do
  file_path = File.join('_site/c',  params[:page] )
  file_path = File.join(file_path, 'index.html') unless file_path =~ /\.[a-z]+$/i  
  p file_path
  if File.exists? file_path
    File.read file_path 
  else 
    404
  end
end
