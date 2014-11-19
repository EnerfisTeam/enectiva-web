module Jekyll

  class SolutionPage < Page
    def initialize(site, base, source_dir, filename, target_dir, siblings)
      @site = site
      @base = base
      @dir = target_dir
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, source_dir), filename)
      self.data['siblings'] = siblings
      self.data['layout'] = 'solution'
    end
  end

  class SolutionPageGenerator < Generator
    safe true

    SOLUTIONS_DIR = '_solutions'

    def generate(site)
      solution_enabled_pages(site).each do |f|
        solutions_path = f.path.match /.+?\/[^\/]+/

        files = read_dir "#{SOLUTIONS_DIR}/#{solutions_path}/"
        siblings = siblings(files, solutions_path.to_s)
        files.each do |dir, filename|
          target = "#{solutions_path}/#{filename}".gsub('.html', '')
          only_siblings = strip_current(siblings, filename)
          site.pages << SolutionPage.new(site,site.source, dir, filename, target, only_siblings)
        end
      end
    end

    def solution_enabled_pages(site)
      site.pages.select { |page| page.data['solutions'] }
    end

    def read_dir(dir)
      Dir.entries(dir).map do |filename|
        path = "#{dir}#{filename}"
        if File.file? path
          [dir, filename]
        else
          nil
        end
      end.compact
    end

    def siblings(files, base_dir)
      files.map do |dir, filename|
        content = File.read("#{dir}#{filename}")
        path = filename.gsub(/.html/, '')
        name = path
        path = '/' + base_dir + '/' + path
        content.match /---(.+?)---/m do |yaml|
          data = SafeYAML.load yaml[1]
          if data and data['title']
            name = data['title']
          end
        end

        {
            'path' => path,
            'name' => name
        }
      end
    end

    def strip_current(siblings, current)
      current = current.gsub('.html', '')

      siblings.select do |sibling|
        not sibling['path'].match current
      end
    end
  end

end