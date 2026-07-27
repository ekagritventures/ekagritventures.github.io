module Jekyll
  # Auto-generate a clean, collision-proof URL slug from each post's `title`.
  #
  # Also renames source files in `_posts/` so the filename becomes
  # `YYYY-MM-DD-slugified-title.md` (e.g. `2026-07-27-craftsmanship.md`),
  # keeping bare `YYYY-MM-DD.md` files alive until a title is filled in.
  #
  # Authoring stays dead simple: in Obsidian you write only a `title:` and the
  # build turns it into the URL /slugified-title/. No two posts can ever share a
  # URL — the second to claim a slug gets a date (then a number) appended, while
  # the first/oldest keeps the clean slug.
  #
  # Runs as a Generator at :highest priority so slugs are finalized before
  # anything reads a document's `.url` (notably the wikilinks mapper at :high).
  # A :post_init hook is too early (front matter isn't parsed yet).
  class AutoSlug < Generator
    safe true
    priority :highest

    def generate(site)
      used = {} # the guest list of addresses already handed out this build

      # Deterministic order so the same post always wins the bare slug.
      site.posts.docs.sort_by { |doc| doc.path.to_s }.each do |doc|
        doc.data["slug"] = claim(base_slug(doc), doc, used)
      end

      # Rename source files: YYYY-MM-DD.md → YYYY-MM-DD-slug.md
      site.posts.docs.each do |doc|
        rename_source(doc)
      end
    end

    # The slug a post *wants*, before uniqueness is enforced.
    def base_slug(doc)
      raw   = doc.data["slug"]
      title = doc.data["title"].to_s.strip

      date_like = raw.is_a?(Date) || raw.is_a?(Time) ||
                  raw.to_s.strip =~ /\A\d{4}-\d{2}-\d{2}\z/
      blank = raw.nil? || raw.to_s.strip.empty?

      chosen =
        if !title.empty? && (blank || date_like)
          title                                   # derive from the title
        elsif blank
          post_date(doc) || File.basename(doc.path.to_s, ".*")
        else
          raw.to_s                                # respect an explicit slug
        end

      Jekyll::Utils.slugify(chosen.to_s)
    end

    # Enforce global uniqueness: append the date, then a counter, until free.
    def claim(base, doc, used)
      base = "post" if base.empty?
      return take(base, used) unless used.key?(base)

      dated = "#{base}-#{post_date(doc)}".chomp("-")
      return take(dated, used) unless used.key?(dated) || dated == base

      n = 2
      n += 1 while used.key?("#{dated}-#{n}")
      take("#{dated}-#{n}", used)
    end

    def take(slug, used)
      used[slug] = true
      slug
    end

    def post_date(doc)
      date = doc.respond_to?(:date) ? doc.date : doc.data["date"]
      date.respond_to?(:strftime) ? date.strftime("%Y-%m-%d") : nil
    end

    # Rename the post file on disk so its name reflects the slug:
    #   2026-07-27-.md            → 2026-07-27-craftsmanship.md
    #   2026-07-27-something.md   → 2026-07-27-craftsmanship.md  (title changed)
    #   2026-07-27-craftsmanship.md → no-op  (already correct)
    def rename_source(doc)
      slug = doc.data["slug"]
      return if slug.nil? || slug.empty?

      old_path = doc.path.to_s
      ext      = File.extname(old_path)
      bare     = File.basename(old_path, ext)

      match = bare.match(/\A(\d{4}-\d{2}-\d{2})(?:-(.*))?\z/)
      return unless match

      date_part    = match[1]
      new_basename = "#{date_part}-#{slug}#{ext}"
      new_path     = File.join(File.dirname(old_path), new_basename)

      return if old_path == new_path
      return if File.exist?(new_path) && new_path != old_path

      FileUtils.mv(old_path, new_path)
      doc.instance_variable_set(:@path, Pathname.new(new_path))
    end
  end
end
