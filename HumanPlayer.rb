require 'colorize'
require 'yaml'

class HumanPlayer
  def initialize(color)
    @color = color
  end
  
  def get_coord
    gets.chomp.scan(/\d/).map(&:to_i)
  end
  
  def get_coords
    gets.chomp.scan(/\d\D\d|\d\d/).map { |pair| pair.split('').map(&:to_i) }
  end
end