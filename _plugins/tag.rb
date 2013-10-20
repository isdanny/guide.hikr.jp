module Jekyll

  class Site

    attr_accessor :page_tags

    def get_tags()
      if self.page_tags.nil?
        self.page_tags = {}
        self.pages.each do |page|
          if page.data.key? "tags"
            tags = page.data["tags"]
            tags.each do |tag|
              if !self.page_tags.has_key? tag
                self.page_tags[tag] = []
              end
              self.page_tags[tag] << page 
            end
          end
        end
      end
      self.page_tags
    end

    old_payload = self.instance_method(:site_payload)

    define_method(:site_payload) do
      tags = get_tags()
      payload = old_payload.bind(self).call
      payload['site']['tag_names'] = tags.keys.sort
      payload['site']['tags'] = tags
      payload
    end
  end

  class TagPage < Page
    def initialize(site,base,dir,tag, pages)
      @site = site
      @base = base
      @dir = dir
      @name = tag+'.html'
      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'tag_listing.html')
      self.data["tag_listing"] = tag
    end
  end

  class TagPageGenerator < Generator
    safe true

    def generate(site)
      site.get_tags()
      p site.page_tags
      site.page_tags.keys.each do | tag |
        p "adding page #{tag}"
        site.pages << TagPage.new(site, site.source, "tag", tag, site.page_tags[tag] )
      end
    end
  end

end
