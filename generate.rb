#!/usr/bin/ruby

require 'digest'
require 'fileutils'
require 'uglifier'
require 'compass'
require 'compass/sass_compiler'

$env = ARGV[0]

$assets = File.join('static', 'assets-web', '')
$css =  File.join('static', 'css', '')
$sass = File.join('static', 'sass', '')
$javascript = File.join('static', 'javascript')
$manifest = 'rev_manifest.json'
$man_path = File.join('data', $manifest)
$new_path = File.join($assets, 'app.css')

def clean_folders
	FileUtils.rm_rf('assets-web')
	FileUtils.rm_rf($assets)
end

def clean_js
	FileUtils.rm_rf(File.join($javascript, '_setup.js'))
	FileUtils.rm_rf(File.join($javascript, 'setup.js'))
	FileUtils.rm_rf(File.join('layouts', 'partials', 'setup.js'))
end

def rename_file
	old_path = File.join($assets, 'app.css.css')
	FileUtils.mv(old_path, $new_path, :force => true)
end

def extract_md5
	$md5css = (Digest::MD5.hexdigest File.read ($new_path))[0...10]
	if $env == 'debug'
		$md5js = (Digest::MD5.hexdigest File.read (File.join($assets, 'application.js')))[0...10]
	else
        $md5js = (Digest::MD5.hexdigest File.read (File.join($assets, '_application.js')))[0...10]
	end
	$md5resp = (Digest::MD5.hexdigest File.read (File.join($javascript, 'respond.src.js')))[0...10]
end

def move_fp
	Dir.open(File.join('assets-web', 'fp')).each do |p|
		file = File.join('assets-web', 'fp', File.basename(p))
		FileUtils.mv file, 'assets-web', :force => true
	end
	FileUtils.rm_r File.join('assets-web', 'fp')
end

def del_fp
 	Dir.open(File.join('assets-web')).each do |p|
		file = File.join('assets-web', File.basename(p))
		FileUtils.rm file, :force => true
	end
	move_fp
end

def rename_fingerprint
	Dir.open(File.join($assets)).each do |p|
		next unless File.extname(p) == '.css'
		filename = File.basename(p, File.extname(p))
		a = p[0...3]
		newname = a + '-' + $md5css + '.css'
		full_pathold = File.join($assets, p)
		full_pathnew = File.join($assets, newname)
		FileUtils.mv(full_pathold, full_pathnew, :force => true)
	end
	newname = 'application-' + $md5js + '.js'
	if $env == 'debug'
		full_pathold = File.join($assets, 'application.js')
	else
        full_pathold = File.join($assets, '_application.js')
	end
	full_pathnew = File.join($assets, newname)
	FileUtils.mv(full_pathold, full_pathnew, :force => true)

	name = 'respond.src-' + $md5resp + '.js'
	old = File.join($javascript, 'respond.src.js')
	newf = File.join($assets, name)
	FileUtils.copy(old, newf)

	%x(cd #{$assets} && git add *.css *.js)
end

def compile
	Compass.add_configuration 'config.rb'
	if $env == 'debug'
        Compass.configuration.output_style = :expanded
	else
		Compass.configuration.output_style = :compressed
	end
	Compass.configuration.asset_cache_buster
	Compass.configuration.project_path = Dir.pwd
	Compass.sass_compiler.clean!
	Compass.sass_compiler(time: true).compile!
end

def manifest
	File.open($man_path, 'w') { |f|
	f << "{\n"
	f << '  "app.css": "app-' + $md5css + '.css"' << ",\n"
	f << '  "application.js": "application-' + $md5js + '.js"' << ",\n"
	f << '  "respond.src.js": "respond.src-' + $md5resp + '.js"' << "\n"
	f << "}\n"
	}
end

def concat_javascript
	File.open(File.join($assets, 'application.js'), 'a') do |mergedfile|
		text = File.open(File.join($javascript, 'jquery.swipebox.js'), 'r').read
		text.each_line do |line|
			mergedfile << line
		end
		text = File.open(File.join($javascript, 'jquery.waypoints.js'), 'r').read
		text.each_line do |line|
			mergedfile << line
		end
		text = File.open(File.join($javascript, 'slick.js'), 'r').read
		text.each_line do |line|
			mergedfile << line
		end
		text = File.open(File.join($javascript, 'app.js.js'), 'r').read
		text.each_line do |line|
			mergedfile << line
		end
		text = File.open(File.join($javascript, 'features.js.js'), 'r').read
		text.each_line do |line|
			mergedfile << line
		end
	end
	setup = File.join($javascript, 'setup.js.js')
	path = File.join($javascript, 'setup.js')
	if $env == 'debug'
    File.open(path, 'w') do |f|
			f.write Uglifier.compile(File.read(setup))
		end
	else
		FileUtils.cp(setup, path)
	end
end

def move_setup
	if $env == 'debug'
        set_new = File.join($javascript, 'setup.js')
	else
		set_new = File.join($javascript, '_setup.js')
	end

	layout = File.join('layouts', 'partials', 'setup.js')
	FileUtils.cp(set_new, layout)
end

def uglifier
	app_old = File.join($assets, 'application.js')
	app_new = File.join($assets, '_application.js')
	File.open(app_new, 'w') do |f|
		f.write Uglifier.compile File.read(app_old)
	end
	File.delete(app_old)
	set_old = File.join($javascript, 'setup.js')
	set_new = File.join($javascript, '_setup.js')
	File.open(set_new, 'w') do |f|
		f.write Uglifier.compile File.read(set_old)
	end
end
unless ARGV.empty?
	unless $env == 'debug'
		abort("Invalid arguments. Please use debug or empty\nExiting")
	end
end

def copyassets
	FileUtils.cp_r 'static/images/.', 'assets-web'
	FileUtils.cp_r 'static/fonts/.', 'assets-web'
end

def copystatic
	FileUtils.cp_r "assets-web/.", "static/assets-web"
	FileUtils.rm_r 'assets-web'
end

puts '======================================================================'
puts ''
puts ''
puts ''
puts ''
puts ''
if $env == 'debug'
	puts "			Compiling in #{$env} mode!! "
else
	puts '			Compiling in normal mode!!'
end
puts ''
puts ''
puts ''
puts ''
puts ''
puts '======================================================================'


# Clean all CSS files of folder and JS
puts '==================================='
puts '  Cleaning CSS and JS folders'
puts '==================================='
clean_folders
clean_js

# Exect the command to compile all SASS files.
puts '==========================='
puts '  Compiling SASS files'
puts '==========================='
copyassets
compile
del_fp

# Rename app.css.css to app.css
puts '================================='
puts '  Merging all CSS and all JS'
puts '================================='
rename_file
concat_javascript
uglifier unless $env == 'debug'
move_setup

# Digest extract md5 hash from file and do a 'for' between character 1 and 10
puts '==================='
puts '  Extracting MD5'
puts '==================='
extract_md5

# Renaming file with fingerprint
puts '==============================================================='
puts "  Renaming app.css to app-#{$md5css}.css "
puts "  Renaming application.js to application-#{$md5js}.js "
puts "  Renaming respond.src.js to respond.src-#{$md5resp}.js "
puts '==============================================================='
rename_fingerprint

# Creating a rev_manifest.json
puts '==============================================='
puts '  Creating rev_manifest.json '
puts '======='