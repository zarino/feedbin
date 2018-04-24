class Transformers
  LISTS     = Set.new(%w(ul ol).freeze)
  LIST_ITEM = 'li'.freeze
  TABLE_ITEMS = Set.new(%w(tr td th).freeze)
  TABLE = 'table'.freeze
  TABLE_SECTIONS = Set.new(%w(thead tbody tfoot).freeze)

  def iframe_whitelist
    lambda { |env|
      node      = env[:node]
      node_name = env[:node_name]
      source    = node['src']

      begin
        parsed_source = URI(source)
      rescue
        return
      end

      if node_name != 'iframe' || env[:is_whitelisted] || !node.element? || source.nil?
        return
      end

      known_hosts = [
        {
          title: "YouTube",
          host: "youtube.com",
          host_regex: /^
                        (?:https?:\/\/|\/\/)
                        (?:www\.)?
                        (?:youtube\.com|youtu\.be|youtube-nocookie\.com)
                      /x
        },
        {
          title: "Vimeo",
          host: "vimeo.com",
          host_regex: /^
                        (?:https?:\/\/|\/\/)
                        (?:www\.|player\.)?
                        (?:vimeo\.com)
                      /x
        },
        {
          title: "Kickstarter",
          host: "kickstarter.com",
          host_regex: /^
                        (?:https?:\/\/|\/\/)
                        (?:www\.)?
                        (?:kickstarter\.com)
                      /x
        },
        {
          title: "Spotify",
          host: "spotify.com",
          host_regex: /^
                        (?:https?:\/\/|\/\/)
                        (?:embed\.spotify\.com)
                      /x
        },
        {
          title: "SoundCloud",
          host: "soundcloud.com",
          host_regex: /^
                        (?:https?:\/\/|\/\/)
                        (?:w\.soundcloud\.com)
                      /x
        },
        {
          title: "Video",
          host: "vzaar.com",
          host_regex: /^
                        (?:https?:\/\/|\/\/)
                        (?:view\.vzaar\.com)
                      /x
        },
        {
          title: "Vine",
          host: "vine.co",
          host_regex: /^
                        (?:https?:\/\/|\/\/)
                        (?:vine\.co)
                      /x
        },
        {
          title: "Chart",
          host: "infogr.am",
          host_regex: /^
                        (?:https?:\/\/|\/\/)
                        (?:e\.)?
                        (?:infogr\.am)
                      /x
        },
        {
          title: "Flickr",
          host: "flickr.com",
          host_regex: /^
                        (?:https?:\/\/|\/\/)
                        (?:www\.flickr\.com)
                      /x
        },
        {
          title: "Mpora",
          host: "mpora.com",
          host_regex: /^
                        (?:https?:\/\/|\/\/)
                        (?:mpora\.com)
                      /x
        },
        {
          title: "TED",
          host: "ted.com",
          host_regex: /^
                        (?:https?:\/\/|\/\/)
                        (?:embed-ssl\.ted\.com)
                      /x
        },
        {
          title: "Tumblr",
          host: "tumblr.com",
          host_regex: /^
                        (?:https?:\/\/|\/\/)
                        (?:www\.tumblr\.com)
                      /x
        },
        {
          title: "Video",
          host: "embedly.com",
          host_regex: /^
                        (?:https?:\/\/|\/\/)
                        (?:cdn\.embedly\.com)
                      /x
        },
        {
          title: "iTunes",
          host: "itunes.apple.com",
          host_regex: /^
                        (?:https?:\/\/|\/\/)
                        (?:embed\.itunes\.apple\.com)
                      /x
        },
      ]


      default_embed_info = {
        title: "",
        host: parsed_source.host
      }

      embed_info = known_hosts.find { |known_host| !!(source =~ known_host[:host_regex]) } || default_embed_info

      new_node = node.document.create_element "div"
      new_node["class"] = "iframe-embed"
      new_node["data-behavior"] = "iframe_embed"
      new_node["data-embed-title"] = embed_info[:title]
      new_node["data-embed-host"] = embed_info[:host]
      new_node["data-embed-source"] = source

      new_node.inner_html = node["src"]
      node.replace new_node

      {node_whitelist: [new_node]}
    }
  end



  def class_whitelist
    lambda do |env|
      node = env[:node]

      if env[:node_name] != 'blockquote' || env[:is_whitelisted] || !node.element? || node['class'].nil?
        return
      end

      allowed_classes = ['twitter-tweet', 'instagram-media', 'imgur-embed-pub']

      allowed_attributes = []

      allowed_classes.each do |allowed_class|
        if node['class'].include?(allowed_class)
          node['class'] = allowed_class
          allowed_attributes = ['class', :data]
        end
      end

      whitelist = Feedbin::Application.config.base.dup
      whitelist[:attributes]['blockquote'] = allowed_attributes

      Sanitize.clean_node!(node, whitelist)

      {node_whitelist: [node]}
    end
  end

  # Top-level <li> elements are removed because they can break out of
  # containing markup.
  def top_level_li
    lambda do |env|
      name, node = env[:node_name], env[:node]
      if name == LIST_ITEM && !node.ancestors.any?{ |n| LISTS.include?(n.name) }
        node.replace(node.children)
      end
    end
  end

  # Table child elements that are not contained by a <table> are removed.
  def table_elements
    lambda do |env|
      name, node = env[:node_name], env[:node]
      if (TABLE_SECTIONS.include?(name) || TABLE_ITEMS.include?(name)) && !node.ancestors.any? { |n| n.name == TABLE }
        node.replace(node.children)
      end
    end
  end

end