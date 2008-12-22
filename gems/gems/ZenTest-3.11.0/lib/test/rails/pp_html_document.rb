class HTML::Document
  def pretty_print(q)
    q.object_address_group self do
      q.breakable
      q.seplist @root.children_without_newlines do |v| q.pp v end
    end
  end
end
  
class HTML::Node
  def children_without_newlines
    @children.reject do |c|
      HTML::Text == c.class and c.content_without_whitespace == "\n"
    end
  end

  def pretty_print(q)
    q.group 1, '[NODE ', ']' do
      q.breakable
      q.seplist children_without_newlines do |v| q.pp v end
    end
  end
end

class HTML::Tag
  def pretty_print(q)
    case @closing
    when :close then
      q.text "[close #{@name}]"
    when :self then
      pretty_print_tag 'empty', q
    when nil then
      pretty_print_tag 'open ', q
    else
      raise "Unknown closing #{@closing.inspect}"
    end
  end

  def pretty_print_tag(type, q)
    q.group 1, "(#{type} #{@name.inspect}", ')' do
      unless @attributes.empty? then
        q.breakable
        q.pp @attributes
      end
      unless children_without_newlines.empty? then
        q.breakable
        q.group 1, '[', ']' do
          q.seplist children_without_newlines do |v|
            q.pp v
          end
        end
      end
    end
  end
end

class HTML::Text
  def content_without_whitespace
    @content.gsub(/^[ ]+/, '').sub(/[ ]+\Z/, '')
  end

  def pretty_print(q)
    q.pp content_without_whitespace
  end
end

class HTML::CDATA
  def pretty_print(q)
    q.group 1, '[', ']' do
      q.pp @content
    end
  end
end

