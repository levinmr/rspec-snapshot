require "json"

class JSONSerializer
  def dump(object)
    JSON.pretty_generate(JSON.parse(object))
  end
end
