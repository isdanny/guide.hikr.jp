module Jekyll

  class SearchData < Page
    def initialize(site,base,dir,character,results)
      @site = site
      @base = base
      @dir = dir
      @name = character+'.json'
      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'search.json')
      self.data['courses'] = pages
    end
  end

  class HikrGenerator < Generator
    safe true

    def generate(site)
      ignored_keywords = [ 'and', 'the', 'a', '-', ',', '.' ]
      index = Hash.new
      site.pages.each do |page|
        keywords = Array.new
        title = ''
        if page.data.has_key? 'title'
          (keywords.concat page.data['title'].split(/\s/)).flatten!
          title = page.data['title']
        end
        if page.data.has_key? 'label'
          title = page.data['label']['en']
        end
        ignored_keywords.each do |ign|
          keywords.delete(ign)
        end
        keywords.each do |keyword|
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
        #File.open(path, 'w') do |f|
        #  f.puts YAML::dump index[first_letter]
        #end
      end
      p index
    end
  end

end
