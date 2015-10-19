# picasa-contents-parser
## What is it?
A parser of [Picasa Web Album](https://picasaweb.google.com).  
This program reads a shared URL of a album, and generate a list of its contens and URLs as JSON.  
This is aimed to use on sequential contents. (e.g. Anime, Net radio etc.)

## Installation
1. `git clone https://github.com/uyorum/picasa-album-parser.git`
1. `gem install bundler`
1. `bundle install`

## How to use
1. Get the shared URL of the web album of picasa. (https://picasaweb.google.com/<user-id>/<album-name>?authkey=XXXXXXXXXXXXXXXX)
1. `cp config.yml.example config.yml`
1. Fullfill the yaml.

    * shared_url  
    The URL you got above.
    * title_regexp  
    Regular expression matches to the filename of the album.  
    This program use it and create a JSON.
    * output  
    The filename of the json.

1. `bundle exec ruby main.rb`
