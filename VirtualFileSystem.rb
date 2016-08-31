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
    @text.concat(s)
  end
end

class VirtualDirectory
  attr_reader :name, :children
  
  def initialize(name)
    @name = name
    @children = {}
  end

  def get(name)
    @children[name]
  end

  def ls
    @children.map{ |k,v| k }
  end

  def has_item?(name)
    @children.has_key?(name)
  end

  def has_file?(name)
    @children[name].is_a?(VirtualFile)
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

  def trace(path)
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

  def ls(path=nil)
    names = []
    if path == nil
      top = @current[-1]
      top.ls
    else
      tmp = trace(path)
      return nil if tmp == nil
      dir, name = tmp
      name.chomp("/")
      if name == nil || name == "."
        dir[-1].ls
      elsif name == ".."
        if dir.length > 1
          dir.pop
          dir[-1].ls
        else
          nil
        end
      else
        return nil unless dir[-1].has_item?(name)
        f = dir[-1].get(name)
        if f.is_a?(VirtualFile)
          [path]
        elsif f.is_a?(VirtualDirectory)
          f.ls
        end
      end
    end
  end

  def cd(path=nil)
    if path == nil
      @current = [@root]
      return true
    end
    tmp = trace(path)
    return false if tmp == nil
    dir, name = tmp
    if name == nil
      @current = [@root]
      return true
    end
    name.chomp!("/")
    if name == "."
    elsif name == ".."
      if dir.length > 1
        dir.pop
      else
        return false
      end
    elsif dir[-1].has_directory?(name)
      dir << dir[-1].get(name)
    else
      return false
    end
    @current = dir
    true
  end

  def pwd
    @current.map{ |s| if s.name == nil then "" else s.name end }.join("/")
  end

  def touch(path)
    tmp = trace(path)
    return false if tmp == nil
    dir, name = tmp
    if name[-1] == "/"
      false
    else
      dir[-1].add(VirtualFile.new(name))
    end
  end

  def mkdir(path)
    tmp = trace(path)
    return false if tmp == nil
    dir, name = tmp
    if name == nil
      return false
    end
    name.chomp!("/")
    if name == "." || name == ".."
      false
    else
      dir[-1].add(VirtualDirectory.new(name))
    end
  end

  def write_line(path, args)
    tmp = trace(path)
    return false if tmp == nil
    dir, name = tmp
    if dir[-1].has_file?(name)
      dir[-1].get(name).append(args.join(" ") + "\n")
      true
    else
      false
    end
  end

  def cat(paths)
    strs = []
    for path in paths
      tmp = trace(path)
      return false if tmp == nil
      dir, name = tmp
      if dir[-1].has_file?(name)
        strs << dir[-1].get(name).get
      else
        return false
      end
    end
    strs.join("")
  end
end
