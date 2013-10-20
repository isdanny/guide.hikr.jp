module Jekyll

  class Site

    attr_accessor :areas
    attr_accessor :prefs
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

    def get_areas()
      if self.prefs.nil?
        self.prefs = {}
        self.pages.each do |page|
          if page.data.key? "prefecture"
            pref = page.data["prefecture"]
            if ! self.prefs.has_key? pref
              self.prefs[pref] = []
            end
            self.prefs[pref] << page
          end
        end
      end
      if self.areas.nil?
        self.areas = {}
        self.pages.each do |page|
          if page.data.key? "area"
            area = page.data["area"]
            if ! self.areas.has_key? area
              self.areas[area] = []
            end
            self.areas[area] << page
          end
        end
      end
      self.areas
    end

    old_payload = self.instance_method(:site_payload)

    define_method(:site_payload) do
      get_areas()
      get_tags()
      payload = old_payload.bind(self).call
      payload['site']['prefecture_names'] = self.prefs.keys.sort{ |b,a| self.prefs[a].size <=> self.prefs[b].size }
      payload['site']['prefectures'] = self.prefs
      payload['site']['area_names'] = self.areas.keys.sort { |b,a| self.areas[a].size <=> self.areas[b].size }
      payload['site']['areas'] = self.areas
      payload['site']['tag_names'] = self.page_tags.keys.sort{ |b,a| self.page_tags[a].size <=> self.page_tags[b].size }
      payload['site']['tags'] = self.page_tags
      payload
    end
  end

  class ListingPage < Page
    def initialize(site,base,dir,area,layout,pages)
      @site = site
      @base = base
      @dir = dir
      @name = area+'.html'
      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), layout)
      self.data['courses'] = pages
      self.data['area_listing'] = area
      self.data['map'] = ['/data/'+dir+'/'+area+'.json']
    end
  end

  class ListingMap < Page
    def initialize(site,base,dir,area, pages)
      @site = site
      @base = base
      @dir = dir
      @name = area+'.json'
      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'maplisting.json')
      self.data['courses'] = pages
    end
  end

  class HikrGenerator < Generator
    safe true

    def generate(site)
      site.get_areas()
      site.get_tags()
      p site.page_tags.keys
      site.areas.keys.each do | area |
        site.pages << ListingPage.new(site, site.source, "area", area, "area.html", site.areas[area])
        site.pages << ListingMap.new(site, site.source, "data/area", area, site.areas[area])
      end
      site.page_tags.keys.each do | tag |
        p "generating #{tag}"
        site.pages << ListingPage.new(site, site.source, "tag", tag, "tag_listing.html", site.page_tags[tag])
        site.pages << ListingMap.new(site, site.source, "data/tag", tag, site.page_tags[tag])
      end
      site.prefs.keys.each do | pref |
        site.pages << ListingPage.new(site, site.source, "pref", pref, "prefecture.html", site.prefs[pref])
        site.pages << ListingMap.new(site, site.source, "data/pref", pref, site.prefs[pref])
      end

    end
  end

end
