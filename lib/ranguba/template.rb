class Ranguba::Template
  def initialize(encodings=nil)
    @encodings = encodings || default_encodings
    @base = Ranguba::Application.config.customize_base_path + 'templates'
    @title_path = @base + 'title.txt'
    @header_path = @base + 'header.txt'
    @footer_path = @base + 'footer.txt'
  end

  def title
    @title ||= Ranguba::File.read(@title_path, @encodings['title.txt'])
  end

  def header
    @header ||= Ranguba::File.read(@header_path, @encodings['header.txt'])
  end

  def footer
    @footer ||= Ranguba::File.read(@footer_path, @encodings['footer.txt'])
  end

  def read(path, encoding='utf-8')
    return '' unless File.exist?(path)
    File.open(path, "r:#{encoding}") {|file| file.read}
  end

  private
  def default_encodings
    {
      'title.txt'  => Encoding.find('utf-8'),
      'header.txt' => Encoding.find('utf-8'),
      'footer.txt' => Encoding.find('utf-8'),
    }
  end
end
