module Jekyll

  class HikrGenerator < Generator
    safe true

    def regenerate(site)
      index = Hash.new
      site.pages.each do |page|
        title = page.data['title']
        if page.data['label']
          title = page.data['label']['en']
        end
        if title
          first_letter = title[0].downcase
          pagedata = { :title=>title, :url=>page.url, :layout=>page.data['layout'] } 
          if index.has_key? first_letter
            index[first_letter] << pagedata
          else
            index[first_letter] = [pagedata]
          end
        end
      end
      index.keys.each do |first_letter|
        path = File.join(ROOT,'data','search',"#{first_letter}.json")
        File.open(path, 'w') do |f|
          f.puts YAML::dump index[first_letter]
        end
      end
      p index
    end
  end

end
