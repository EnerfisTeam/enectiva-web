require 'compass/import-once/activate'
require 'fileutils'
require 'digest'
# Require any additional compass plugins here.

# Set this to the root of your project when deployed:
http_path = "/"
project_path = "/"
asset_path = "assets-web"
css_dir = "/static/assets-web/"
sass_dir = "/static/sass/"
images_dir =  "assets-web"
javascripts_dir =  "/static/js/"
fonts_dir = "assets-web"

# You can select your preferred output style here (can be overridden via the command line):
# output_style = :expanded or :nested or :compact or :compressed
#output_style = :compressed


# To enable relative paths to assets via compass helper functions. Uncomment:
relative_assets = false

# To disable debugging comments that display the original location of your selectors. Uncomment:
line_comments = false

asset_cache_buster do |path, file|
  if file
    pathname = Pathname.new(path)

    hash = (Digest::MD5.hexdigest File.read file)[0...10]
    new_path = "%s/%s-%s%s" % [pathname.dirname, pathname.basename(pathname.extname), hash, pathname.extname]

    oldPath = File.join("#{Dir.pwd}","assets-web", "#{pathname.basename}")
    newPath = File.join("#{Dir.pwd}", "assets-web", "fp", "#{pathname.basename(pathname.extname)}-#{hash}#{pathname.extname}")

    if File.file?(oldPath)
      FileUtils.mkdir_p(File.join("#{Dir.pwd}", "assets-web", "fp"))
      FileUtils.cp_r("#{oldPath}", "#{newPath}")
    end
    
    {:path => new_path, :query => nil}

    #FileUtils.cp_r("#{oldPath}", "#{newPath}")
  end
end


# If you prefer the indented syntax, you might want to regenerate this
# project again passing --syntax sass, or you can uncomment this:
# preferred_syntax = :sass
# and then run:
# sass-convert -R --from scss --to sass sass scss && rm -rf sass && mv scss sass
