module Jekyll
  # Auto-generate a clean URL slug from each post's `title` front matter.
  #
  # Workflow goal: in Obsidian you only write a `title:` — the slug (and thus
  # the URL /your-title/) is derived automatically at build time.
  #
  # Implemented as a Generator at :highest priority so slugs are normalized
  # BEFORE anything computes a document's `.url` (in particular the wikilinks
  # mapper, which runs at :high). A :post_init hook is too early — front matter
  # isn't parsed yet — so a generator is the correct seam.
  #
  # Rules per document:
  #   * slug missing / blank            -> slugify(title)
  #   * slug is a bare date YYYY-MM-DD  -> slugify(title)   (the template's
  #     placeholder default, and the unquoted-date form that crashes the build)
  #   * slug is a real word string      -> left untouched (manual slugs win)
  #   * no usable title but slug is a
  #     Date/Time object                -> stringified, so slugify never
  #     receives a Date and aborts the build
  class AutoSlug < Generator
    safe true
    priority :highest

    def generate(site)
      docs = site.posts.docs + site.collections.values.flat_map(&:docs)
      docs.uniq.each { |doc| fix(doc) }
    end

    def fix(doc)
      raw   = doc.data["slug"]
      title = doc.data["title"].to_s.strip

      date_like = raw.is_a?(Date) || raw.is_a?(Time) ||
                  raw.to_s.strip =~ /\A\d{4}-\d{2}-\d{2}\z/
      blank = raw.nil? || raw.to_s.strip.empty?

      if (blank || date_like) && !title.empty?
        doc.data["slug"] = Jekyll::Utils.slugify(title)
      elsif raw.is_a?(Date) || raw.is_a?(Time)
        doc.data["slug"] = raw.to_s
      elsif blank
        # No title and no slug: never leave it empty (an empty slug collides
        # with the site homepage "/"). Fall back to the post date, else filename.
        date = doc.respond_to?(:date) ? doc.date : doc.data["date"]
        doc.data["slug"] =
          if date.respond_to?(:strftime)
            date.strftime("%Y-%m-%d")
          else
            Jekyll::Utils.slugify(File.basename(doc.path.to_s, ".*"))
          end
      end
    end
  end
end
