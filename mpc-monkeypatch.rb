#some new methods...
class Mpc
  def playing?
    !paused? && !stopped?
  end
  
  def putshack(command)
    puts(command)
  end
end

# Array#second is called in song_list() and I have no idea where that's supposed to come from
class Array
  def second
    self[1]
  end
end
