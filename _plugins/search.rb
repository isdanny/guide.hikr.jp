require 'json'

module Jekyll

  class SearchData < Page
    def initialize(site,base,dir,character,results)
      @site = site
      @base = base
      @dir = dir
      @name = character+'.json'
      p "writing #{dir}/#{@name}"
      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'search.json')
      self.data["results"] = results.to_json
      # self.data['courses'] = pages
    end
  end

  class SearchGenerator < Generator
    safe true

    def generate(side)
    end

    def generate(site)
      p "Generating search index..."
      ignored_keywords = [ ]
      index = Hash.new
      site.pages.each do |page|
        keywords = Array.new
        title = ''
        if page.data.has_key? 'title'
          title = page.data['title']
          (keywords.concat title.split(/\s/)).flatten!
        end
        keywords.map{ |e| e.downcase.strip }
        if page.data.has_key? 'label'
          title = page.data['label']['en']
        end
        keywords.each do |keyword|
          if keyword.length<4
            keywords.delete(keyword)
          end
        end
        ignored_keywords.each do |ign|
          keywords.delete(ign)
        end
        keywords.each do |keyword|
          keyword.downcase!
          first_letter = keyword[0].downcase
          pagedata = { :title=>title, :url=>page.url, :layout=>page.data['layout'] } 
          if ! index.has_key? first_letter
            index[first_letter] = Hash.new
          end
          if ! index[first_letter].has_key? keyword
            index[first_letter][keyword] = Array.new
          end
          index[first_letter][keyword] << pagedata
        end
      end
      index.keys.each do |first_letter|
        path = File.join(ROOT,'data','search',"#{first_letter}.json")
        site.pages << SearchData.new(site, site.source, "data/search", first_letter, index[first_letter] )
      end
    end
  end

end
