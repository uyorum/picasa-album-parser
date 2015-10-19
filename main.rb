require 'nokogiri'
require 'open-uri'
require 'json'
require 'yaml'
require 'erb'
require 'date'

config_yaml_path = "config.yml"
GlobalConfig = YAML.load(ERB.new(File.new(config_yaml_path).read).result)

def parse_album(album)
  shared_url = album["shared_url"]
  title_regexp = Regexp.new(album["title_regexp"])

  doc = Nokogiri::HTML(open(shared_url), nil, 'utf-8')

  feed = {}
  doc.xpath('/html/body/script')[4].to_s.each_line do |l|
    if l =~ /^feedPreload: /
      /^feedPreload: (.*)},$/ =~ l
      feed = JSON.parse($1)["feed"]
    end
  end

  album_info = {}
  album_info["album_title"] = feed["title"]
  album_info["shared_url"] = shared_url
  album_info["rss_url"] = feed["link"].select{|l| l["href"] =~ /https:\/\/picasaweb\.google\.com\/data\/feed\/tiny\/user/}.first["href"]

  contents_list = {}
  feed["entry"].each do |e|
    content = {}
    title_regexp =~ e["media"]["title"]
    %w(title ep).each do |k|
      if Regexp.last_match.names.include?(k)
        content[k] = Regexp.last_match[k]
      else
        content[k] = nil
      end
    end

    episode_date = []
    %w(year month day hour min sec).each do |k|
      if Regexp.last_match.names.include?(k) && Regexp.last_match[k] != nil
        episode_date << Regexp.last_match[k].to_i
      else
        episode_date << 0
      end
    end

    episode = {}
    episode["ep"] = content["ep"]
    episode["date"] = DateTime.new(*episode_date, DateTime.now.offset).to_s
    episode["picasa_link"] = e["link"].select{|l| l["rel"] == "alternate"}.first["href"]
    episode["thumbnail"] = e["media"]["thumbnail"].last["url"]
    episode["content_link"] = e["media"]["content"].select{|c| c["type"] =~ /video/}

    contents_list[content["title"]] ||= []
    contents_list[content["title"]] << episode
  end
  album_info["contents_list"] = contents_list

  File.write(album["output"], JSON.pretty_generate(album_info))
end

GlobalConfig["album_list"].each do |album|
  parse_album(album)
end
