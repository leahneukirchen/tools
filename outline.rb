# To the extent possible under law, Christian Neukirchen has waived
# all copyright and related or neighboring rights to this work.
# http://creativecommons.org/publicdomain/zero/1.0/

class Outline < Array
  def self.parse_dash(file)
    stack = [[]]
    offset = 0
    
    file.each { |line|
      line =~ /^(\s*)(- )?(.*)/
      indent = $1.size - ($2 ? 0 : 2)
      
      if $2 == "- "
        while indent > offset
          offset += 2
          stack << []
        end
        
        while indent < offset
          offset -= 2
          stack[-2] << stack.pop
        end
        
        stack.last << $3
      else
        stack.last << ""  unless stack.last.last
        stack.last.last << "\n" << $3
      end
    }
    
    stack[-2] << stack.pop  while stack.size > 1
    
    new stack.first
  end

  def initialize(outline)
    replace outline
  end

  def headerize(outline=self, depth=0)
    case outline
    when String
      outline.sub(/\A(#+|=+)/) { $&[0..0] * depth }
    when Array
      self.class.new outline.map { |i| headerize(i, depth+1) }
    end
  end

  def dashize(outline=self, depth=0)
    case outline
    when String
      outline.gsub(/^/, "  "*depth).sub(/\A(\s*)  /, "\\1- ") + "\n"
    when Array
      outline.map { |i| dashize(i, depth+1) }.join
    end
  end

  def starize(outline=self, depth=0)
    case outline
    when String
      "#{"*" * depth} #{outline}"
    when Array
      outline.map { |i| starize(i, depth+1) }.join("\n\n")
    end
  end

  def linearize(outline=self, &filter)
    filter ||= lambda { |x| x.to_s.rstrip }
    outline.flatten.map(&filter).join("\n\n")
  end
  alias_method :to_s, :linearize

  def xoxoize(cls=nil, outline=self, &filter)
    filter ||= lambda { |x| x }
    
    case outline
    when String
      filter.call(outline)
    when Array
      "<ul#{cls ? " class=#{cls.dump}" : ""}>#{outline.map { |i| "<li>#{xoxoize(cls, i, &filter)}</li>" }}</ul>".
        gsub(%r|</li><li><ul>|, "<ul>")
    end
  end
  alias_method :to_html, :xoxoize

  def wittgensteinize(dots=true, outline=self, prefix=[])
    case outline
    when String
      if dots
        prefix.join(".") + " " + outline
      else
        prefix[0].to_s + "." + prefix[1..-1].join + " " + outline
      end
    when Array
      n = 0
      self.class.new((0..outline.size).map { |i|
                       n += 1  if outline[i].kind_of? String
                       wittgensteinize(dots, outline[i], prefix+[n])
                     })
    end
  end
end
