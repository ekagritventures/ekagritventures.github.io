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
  # Applies Obsidian-flavored markdown transforms to a chunk of plain text
  # (i.e. text that is NOT inside a code block or inline code span).
  def self.transform_obsidian(text, link_map)
    # Wikilinks: [[Target]] or [[Target|Label]]
    text = text.gsub(/\[\[([^\]]+)\]\]/) do
      inner = Regexp.last_match(1)
      parts = inner.split('|', 2)
      link_target = parts[0].strip
      link_label = parts[1] ? parts[1].strip : link_target
      url = link_map[link_target] || link_map[link_target.downcase]
      url ? "[#{link_label}](#{url})" : link_label
    end

    # Highlights: ==text== -> <mark>text</mark> (single line, ignores ===)
    text = text.gsub(/==(?!=)(?=\S)(.+?)(?<=\S)==(?!=)/) do
      "<mark>#{Regexp.last_match(1)}</mark>"
    end

    text
  end

  # Intercepts content right before rendering to HTML and fixes the links.
  # Code fences (``` / ~~~) and inline code spans (`...`) are left untouched
  # so things like `if x == y` in code never get mangled.
  Jekyll::Hooks.register [:posts, :pages, :documents], :pre_render do |doc|
    link_map = WikilinkManager.link_map || {}
    next unless doc.content

    # Split on fenced code blocks, keeping the fences in the array.
    fence = /(^[ \t]*(?:```|~~~).*?^[ \t]*(?:```|~~~)[ \t]*$)/m
    doc.content = doc.content.split(fence).map do |segment|
      if segment =~ /\A[ \t]*(?:```|~~~)/m
        segment # fenced code block — leave as-is
      else
        # Within prose, protect inline code spans, then transform.
        segment.split(/(`[^`\n]*`)/).map do |piece|
          piece.start_with?('`') ? piece : Jekyll.transform_obsidian(piece, link_map)
        end.join
      end
    end.join
  end
end