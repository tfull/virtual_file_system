# coding: utf-8

class VirtualFile
  attr_reader :name

  def initialize(name)
    @name = name
    @text = ""
  end

  def set(s)
    @text = s
  end

  def get
    @text
  end

  def append(s)
    @text.concat
  end
end

class VirtualDirectory
  attr_reader :name, :children
  
  def initialize(name)
    @name = name
    @children = {}
  end

  def ls
    @children.map{ |k,v| k }
  end

  def has_item?(name)
    @children.has_key?(name)
  end

  def has_directory?(name)
    @children[name].is_a?(VirtualDirectory)
  end

  def add(item)
    name = item.name
    if has_item?(name)
      false
    else
      @children[name] = item
      true
    end
  end

  def rm(item)
    name = item.name
    if has_item?(name)
      @children.delete(name)
      true
    else
      false
    end
  end
end

class VirtualFileSystem
  attr_reader :current

  def initialize
    @root = VirtualDirectory.new(nil)
    @current = [@root]
  end

  def pursue(path) # [path], name
    current = @current.clone
    xs = path.split(/(.*\/)/).select{ |s| ! s.empty? }
    if xs.length == 0
      nil
    else
      if xs[0] == "/"
        current = [@root]
        xs.shift
      end
      for i in 0...(xs.length - 1)
        name = xs[i].chomp("/")
        if name == "" || name == "."
        elsif name == ".."
          if current.length > 1
            current.pop
          else
            return nil
          end
        else
          if current[-1].has_directory?(name)
            current << current[-1].get(name)
          else
            return nil
          end
        end
      end
      [current, xs[-1]]
    end
  end

  def ls(path)
    names = []
    if path == nil
      top = @current[-1]
      top.ls
    end
  end

  def touch(path)
    dir, name = pursue(path)
    if name[-1] == "/"
      false
    else
      dir[-1].add(VirtualFile.new(name))
    end
  end
end
