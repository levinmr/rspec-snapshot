require "nokogiri"

class HtmlSerializer
  def dump(object)
    Nokogiri::HTML(object, &:noblanks).to_xhtml(indent: 2)
  end
end
