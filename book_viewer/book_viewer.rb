require "tilt/erubis"
require "sinatra"
require "sinatra/reloader"

before do
  @contents = File.readlines("data/toc.txt")
end

helpers do
  def in_paragraphs(content)
    id_num = 0

    content.split(/\n\n/).map.with_index do |paragraph, idx|
      "<p id=#{idx.to_s}>" + paragraph + "</p>"
    end.join
  end

  def each_chapter
    @contents.each_with_index do |name, index|
      number = index + 1
      contents = File.read("data/chp#{number}.txt")
      yield number, name, contents
    end
  end

  def each_paragraph(chapter)
    chapter.split(/\n\n/).each_with_index do |paragraph, paragraph_id|
      yield paragraph, paragraph_id
    end
  end

  # results = [
  #   [ # Each chapter
  #     { # Each paragraph
  #       chapter_name => name,
  #       chapter_num => num,
  #       paragraph_id => num,
  #       paragraph => paragraph
  #     },
  #   ]
  # ]
  def chapters_matching(query)
    results = Array.new

    return results if !query || query.empty?

    each_chapter do |number, name, contents|
      chapter_results = Array.new

      each_paragraph(contents) do |paragraph, paragraph_id|
        if paragraph.include?(query)
          chapter_results << {name: name, number: number, paragraph: paragraph, paragraph_id: paragraph_id}
        end
      end

      results << chapter_results unless chapter_results.empty?
    end

    results
  end
end

not_found do
  redirect "/"
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"

  erb :home
end

get "/show/:name" do
  params['name']
end

get "/chapters/:number" do
  chapter_num = params['number'].to_i
  chapter_name = @contents[chapter_num - 1]

  @title = "Chapter #{chapter_num}: #{chapter_name}"

  @chapter = in_paragraphs(File.read("data/chp#{chapter_num}.txt"))

  erb :chapter
end

get "/search" do
  @results = chapters_matching(params[:query])
  erb :search
end
