require 'tilt/erubis'
require "sinatra"
require "sinatra/reloader"

get "/*" do

  # LS version
  # @files = Dir.glob("public/*").map {|file| File.basename(file) }.sort
  # @files.reverse! if params[:sort] == "desc"
  # erb :home

  # @files = Dir.glob("public/*").reject do |path|
  #   File.directory?(path)
  # end

  @files.map! do |file|
    File.basename(file)
  end

  if params['sort'] == 'desc'
    @files.reverse!
  end

  erb :home
end
