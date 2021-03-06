class Ranguba::Entry < ActiveGroonga::Base
  DEFAULT_SUMMARY_SIZE = 140

  table_name("entries")
  reference_class("encoding", Ranguba::Encoding)
  reference_class("mime_type", Ranguba::MimeType)
  reference_class("type", Ranguba::Type)
  reference_class("author", Ranguba::Author)
  reference_class("category", Ranguba::Category)
  reference_class("extension", Ranguba::Extension)

  before_validation do
    if body.empty?
      self.content_length = 0
    else
      self.content_length = body.bytesize
    end
  end

  def title
    _title = super
    if _title and !_title.valid_encoding?
      logger.warn("#{Time.now} [encoding][invalid][title] " +
                  "key: #{key}: #{_title.inspect}")
      _title = nil
    end
    return _title unless _title.blank?
    _url = url
    if _url and !_url.valid_encoding?
      logger.warn("#{Time.now} [encoding][invalid][title][fallback][url] " +
                  "key: #{key}: <#{_url.inspect}>")
      _url = ""
    end
    _url
  end

  def url
    key
  end

  def category
    _category = super
    _category = _category.key if _category
    _category
  end

  def type
    _type = super
    _type = _type.key if _type
    _type
  end

  def drilldown_entries
    @drilldown_entries ||= compute_drilldown_entries
  end

  def summary(expression, options={})
    if body && !body.valid_encoding?
      logger.warn "#{Time.now} [encoding][invalid][body] key: #{key}"
      return ""
    end
    summary = summary_by_query(expression, options)
    summary = summary_by_head(options) if summary.blank?
    summary
  end

  def summary_by_head(options={})
    options = normalize_summary_options(options)
    summary = body
    if !summary.blank? && summary.size > options[:size]
      summary = summary[0..(options[:size]-1)] + options[:separator]
    end
    summary
  end

  def summary_by_query(expression, options={})
    return "" unless expression

    options = normalize_summary_options(options)

    highlight_tags = options[:highlight].split("%S")

    snippet_options = {
      :normalize => true,
      :width => options[:size],
      :html_escape => options[:html_escape]
    }

    snippet = expression.snippet(highlight_tags, snippet_options)
    snippet ||= Groonga::Snippet.new(snippet_options)

    summarized = ""
    if snippet && !body.blank?
      snippets = snippet.execute(body)
      unless snippets.empty?
        snippets = snippets.collect do |snippet|
          options[:part].sub("%S", "#{options[:separator]}#{snippet}#{options[:separator]}")
        end
        summarized = snippets.join("").html_safe
      end
    end
    summarized
  end

  private
  def compute_drilldown_entries
    entries = []
    Ranguba::SearchRequest::KEYS.each do |key|
      next if key == :query || send(key).blank?
      entries << Ranguba::DrilldownEntry.new(:key => key,
                                             :value => send(key))
    end
    entries
  end

  def normalize_summary_options(options={})
    options[:size] ||= DEFAULT_SUMMARY_SIZE
    options[:highlight] ||= "*%S*"
    options[:separator] ||= "..."
    options[:part] ||= "%S"
    options
  end
end

