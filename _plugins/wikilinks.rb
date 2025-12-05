module Jekyll
  class Wikilinks < Generator
    safe true
    priority :low

    def generate(site)
      # 1. Build a map of { Title/Filename => URL }
      link_map = {}

      # Helper to add to map
      add_to_map = ->(item) {
        url = item.url
        
        # Map by Title (if exists)
        if item.data['title']
          title = item.data['title'].strip
          link_map[title] = url
          link_map[title.downcase] = url # Case insensitive fallback?
        end

        # Map by Filename (basename without extension)
        basename = File.basename(item.path, ".*")
        link_map[basename] = url
        link_map[basename.downcase] = url
      }

      site.posts.docs.each(&add_to_map)
      site.pages.each(&add_to_map)
      # Add collections if any
      site.collections.each do |name, collection|
        next if name == 'posts' # already handled
        collection.docs.each(&add_to_map)
      end

      # 2. Replace [[Link]] in all content
      process_content = ->(item) {
        next unless item.content.is_a?(String)
        
        # New simplified logic:
        # 1. Match anything inside [[ ... ]] that isn't a closing bracket
        # 2. Split by pipe manually
        
        item.content = item.content.gsub(/\[\[([^\]]+)\]\]/) do |match|
          # 'match' is "[[Target|Label]]"
          # 'inner' is "Target|Label"
          inner = Regexp.last_match(1)
          
          # Split by pipe. limit: 2 ensures we only split on the first pipe if multiple exist (unlikely but safe)
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
      }

      site.posts.docs.each(&process_content)
      site.pages.each(&process_content)
      site.collections.each do |name, collection|
        next if name == 'posts'
        collection.docs.each(&process_content)
      end
    end
  end
end
