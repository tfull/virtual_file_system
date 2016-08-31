# coding: utf-8

class VirtualFile
  attr_reader :name

  def initialize(name)
    @name = name
    @lines = []
  end
end

class VirtualDirectory
  attr_reader :name, :children
  
  def initialize(name)
    @name = name
    @children = []
  end
end

class VirtualFileSystem
  attr_reader :current

  def initialize
    @current = [VirtualDirectory.new(nil)]
  end

  def pursue(path)
    current = @current.clone
    xs = path.split("/")
    if xs.length == 0
    end
  end

  def ls(path)
    names = []
    if path == nil
      @current.children.each do |item|
        names << item.name.clone
      end
    end
    names
  end

  def touch(path)
  end
end
