module Jekyll
  class WikilinkManager
    # Singleton to hold the link map across the build lifecycle
    class << self
      attr_accessor :link_map
    end
  end

  # Phase 1: The Mapper (Generator)
  # Scans all files to build the dictionary of { "File Name" => "URL" }
  class WikilinkMapper < Generator
    safe true
    priority :high # Run early to build the map before anyone needs it

    def generate(site)
      map = {}

      add_to_map = ->(item) {
        url = item.url
        
        # Map by Title
        if item.data['title']
          title = item.data['title'].strip
          map[title] = url
          map[title.downcase] = url
        end

        # Map by Filename (basename without extension)
        basename = File.basename(item.path, ".*")
        map[basename] = url
        map[basename.downcase] = url
      }

      site.posts.docs.each(&add_to_map)
      site.pages.each(&add_to_map)
      site.collections.each do |name, collection|
        next if name == 'posts'
        collection.docs.each(&add_to_map)
      end

      WikilinkManager.link_map = map
    end
  end

  # Phase 2: The Interceptor (Hook)
  # Intercepts content right before rendering to HTML and fixes the links
  Jekyll::Hooks.register [:posts, :pages, :documents], :pre_render do |doc|
    link_map = WikilinkManager.link_map || {}
    
    # Check if content exists
    if doc.content
      doc.content = doc.content.gsub(/\[\[([^\]]+)\]\]/) do |match|
        inner = Regexp.last_match(1)
        
        parts = inner.split('|', 2)
        link_target = parts[0].strip
        link_label = parts[1] ? parts[1].strip : link_target
        
        url = link_map[link_target] || link_map[link_target.downcase]

        if url
          "[#{link_label}](#{url})"
        else
          link_label
        end
      end
    end
  end
end