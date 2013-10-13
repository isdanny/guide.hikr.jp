module Jekyll

  class Site

  end

  class AreaPage < Page
    def initialize(site,base,dir,area, pages)
      @site = site
      @base = base
      @dir = dir
      @name = area+'.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'area.html')
      self.data['area'] = area
      self.data['pages'] = pages

    end
  end

  class AreaPageGenerator < Generator
    safe true

    def generate(site)
      areas = {}
      site.pages.each do |page|
        if page.data.key? "area"
          area = page.data["area"]
          if ! areas.key? area
            areas[area] = []
          end
          areas[area].push(page)
        end
      end
      areas.keys.each do | area |
        site.pages << AreaPage.new(site, site.source, "area", area, areas[area])
      end
      p site.source
    end
  end

end