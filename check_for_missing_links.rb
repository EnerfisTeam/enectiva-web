require 'net/http'
require 'set'


scheme = 'http'
host = 'energyanalytics.eu'
base_url = '/cs/o-enective'
locales_to_ignore = [:ru, :sk]
# Used to filter out paths which are not expected to be translated, must match anywhere in the path
snippets_to_skip = %w(/blog /password /login /media)

def parse_redirect(scheme, host, url, response)
  location = response['location']
  match = location.match "#{scheme}://#{host}(.+)"
  if match
    match[1]
  else
    location
  end
end

def fetch_html(scheme, host, location, limit = 10)
  # You should choose better exception.
  raise ArgumentError, 'HTTP redirect too deep' if limit == 0

  url = URI.parse("#{scheme}://#{host}#{location}")
  req = Net::HTTP::Get.new(url.path)
  response = Net::HTTP.start(url.host, url.port) { |http| http.request(req) }
  case response
    when Net::HTTPSuccess     then response.body
    when Net::HTTPRedirection then fetch_html(scheme, host, parse_redirect(scheme, host, url, response), limit - 1)
    else
      response.error!
  end
end

def extract_urls(context, html, snippets_to_skip)
  # Find all href attributes
  urls = html.scan(/href=["'](.+?)["']/).flatten

  # Filter out links to specific extension (assets)
  urls = urls.find_all do |url|
    if url.match /\..{2,3}$/
      false
    elsif url.match /^http/
      false
    elsif url.length == 3 # Only base locale
      false
    elsif url.match Regexp.new snippets_to_skip.join '|'
      false
    else
      true
    end
  end.map do |url| # Prepend relative URLs by current context
    if url[0] == '/'
      url
    else
      "#{context}/#{url}"
    end
  end.map do |url| # Strip #link
    match = url.match /(.+)#(.+)$/
    if match
      match[1]
    else
      url
    end
  end
  Set.new urls
end

def extract_translations(url, html)
  links = html.scan(/<a.+?(?:href=['"](.+?)['"])?.+?hreflang=['"](.+?)['"].+?(?:href=['"](.+?)['"])?.+?>/)

  translations = {}
  links.each do |link|
    translations[link[1].to_sym] = link[0] || link[2]
  end

  if links
    {
      url: url,
      locale: url.split('/')[1].to_sym,
      translations: translations
    }
  else
    nil
  end
end


errors = []
urls_processed = Set.new
urls_to_process = Set.new [base_url]

localized_paths = {}

i = 1
until urls_to_process.empty?

  # Get one URL
  url = urls_to_process.take(1).first
  urls_to_process.delete(url)

  # Mark URL as processed
  urls_processed << url

  puts "Iteration #{i}, running #{url}, processed: #{urls_processed.size}, still left to process: #{urls_to_process.size}"

  # Fetch HTML
  begin
    html = fetch_html scheme, host, url
  rescue Net::HTTPServerException => e
    errors << {
      url: url,
      exception: e
    }
  end

  # Extract all links
  links = extract_urls(url, html, snippets_to_skip)
  # Add non-visited links to the list
  urls_to_process.merge (links - urls_processed)

  # Extract links to other translations of this page
  translations = extract_translations url, html
  if translations
    localized_paths[url] = translations
  end

  i += 1
  # break if i == 10
end



def identify_locales(paths, locales_to_ignore)
  paths.map { |_, p| p[:locale] }.uniq - locales_to_ignore
end

# Count locales which were linked at least once
locales_encountered = identify_locales localized_paths, locales_to_ignore
locales_count = locales_encountered.count
puts "Found #{locales_count} locales: #{locales_encountered.join ', '}, ignored: #{locales_to_ignore.join ', '}"

# Segment localized_paths into interlinking groups
groups = []
until localized_paths.empty?
  group = []
  paths_in_group = Set.new [localized_paths.first[0]]
  processed_in_group = Set.new []

  until paths_in_group.empty?
    path = paths_in_group.take(1).first
    paths_in_group.delete(path)
    processed_in_group << path

    translation = localized_paths.delete path
    next if translation.nil?

    group << translation

    paths_in_group.merge(Set.new(translation[:translations].values) - processed_in_group)
  end

  groups << group
end

def check_group_for_completeness(group, locales)
  paths = group.map { |p| p[:url] }.sort

  locales_in_group = group.map { |p| p[:locale] }

  if locales_in_group != locales
    (locales - locales_in_group).each do |missing_locale|
      paths << "/#{missing_locale}/???"
    end
  end
  links = {}
  group.each { |p| links[p[:url]] = p[:translations].values }

  links_present = []
  paths.count.times do |i|
    links_present[i] = Array.new(paths.count, nil)
  end

  paths.each_with_index do |row_path, i|
    paths.each_with_index do |col_path, j|
      links_present[i][j] = if row_path == col_path
                              nil
                            elsif not links.key? row_path
                              false
                            else
                              links[row_path].include? col_path
                            end
    end
  end

  {
    complete: !links_present.flatten.include?(false),
    matrix: links_present,
    paths: paths
  }
end

def print_row(length, row)
  format = "%-#{length}s"
  x = row.map do |cell|
    format % cell
  end
  puts x.join ' | '
end

def print_line(length, cols)

  print_row length, cols.times.map { (length).times.map { '-' }.join '' }
end

def print_formatted_matrix(group)
  length = group[:paths].map { |p| p.length }.max

  puts ''
  puts ''
  print_row length, ['row -> col'] + group[:paths]
  print_line length, group[:paths].count + 1
  group[:paths].each_with_index do |path, i|
    print_row length, [path] + group[:matrix][i]
  end
end

puts "Found #{groups.count} groups, only incomplete will be printed"
groups.each do |group|
  group = check_group_for_completeness group, locales_encountered
  next if group[:complete]

  print_formatted_matrix group
end

puts "Errors encountered:"
errors.each do |error|
  puts "\t#{error[:url]}: #{error[:exception]}"
end