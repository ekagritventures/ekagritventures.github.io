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
        
        item.content = item.content.gsub(/\[\[(.*?)(?:\|(.*?))?\]\]/) do |match|
          link_target = Regexp.last_match(1).strip
          link_label = Regexp.last_match(2) || link_target
          
          url = link_map[link_target] || link_map[link_target.downcase]

          if url
            "[#{link_label}](#{url})"
          else
            # Link not found: Keep it as text or make a broken link?
            # Sticking to Obsidian style: it's a link to a missing page.
            # But for the blog, let's just render the text to avoid 404s.
            # Or user might want to know it's missing.
            # Let's keep it as text for now to look clean.
            link_label
            # Alternatively: "<span class='broken-link'>#{link_label}</span>"
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
