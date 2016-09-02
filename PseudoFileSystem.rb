class PseudoFileSystem
  def initialize(home, vpath="/home")
    @home = home
    @current = [home]
    @virtual_path = vpath
  end

  def trace(path)
    current = @current.clone
    xs = path.split(/(.*?\/)/).select{ |s| !s.empty? }
    if xs.length == 0
      nil
    else
      if xs[0] == "~/"
        current = [@home]
        xs.shift
      else xs[0] == "/"
        return nil
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
          current << name
        end
      end
    end
    [current, xs[-1]]
  end

  def cd(path)
    tmp = trace(path)
    return false if tmp == nil
    dir, name = tmp
    name.chomp!("/")
    if name == "" || name == "."
    elsif name == ".."
      if dir.length > 1
        dir.pop
      else
        false
      end
    else
      dir << name
    end
    if File::directory?(dir.join("/"))
      @current = dir
      true
    else
      false
    end
  end

  def pwd
    dir = @current.clone
    dir[0] = @virtual_path
    dir.join("/")
  end

  def ls(path=nil)
    if path == nil
      `ls #{@current.join("/")}`
    else
      tmp = trace(path)
      return nil if tmp == nil
      dir, name = tmp
      name.chomp!("/")
      p(name)
      p(dir)
      if name == ".." && dir.length < 2
        return nil
      end
      str = `ls #{dir.join("/")}/#{name}`
      stat = ($?.exitstatus == 0)
      if stat then str else nil end
    end
  end

  def mkdir(path)
    tmp = trace(path)
    return false if tmp == nil
    dir, name = tmp
    `mkdir -p #{dir.join("/")}/#{name}`
    $?.exitstatus == 0
  end

  def touch(path)
    tmp = trace(path)
    return false if tmp == nil
    dir, name = tmp
    `touch #{dir.join("/")}/#{name}`
    $?.exitstatus == 0
  end

  def write_line(path, args)
    tmp = trace(path)
    return false if tmp == nil
    dir, name = tmp
    `echo #{args.join(" ")} >> #{dir.join("/")}/#{name}`
    $?.exitstatus == 0
  end

  def rm(path)
    tmp = trace(path)
    return false tmp == nil
    dir, name = tmp
    `rm #{dir.join("/")}/#{name}`
    $?.exitstatus == 0
  end

  def wc(path)
    tmp = trace(path)
    return false tmp == nil
    dir, name = tmp
    result = `wc #{dir.join("/")}/#{name}`
    stat = ($?.exitstatus == 0)
    if stat then result else nil end
  end

  def view(inst, path)
    tmp = trace(path)
    return false tmp == nil
    dir, name = tmp
    result = `sed -n #{inst}p #{dir.join("/")}/#{name}`
    stat = ($?.exitstatus == 0)
    if stat then result else nil end
end
