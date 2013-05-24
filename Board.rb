require 'colorize'
require 'yaml'
require './checkers.rb'
require './Piece.rb'
require './BoardOperations.rb'

class Board
  include BoardOperations
  attr_reader :board
  
  def initialize
    @board = generate_board
  end
  
  def slide_piece(piece, move)
    clear_space([piece.row, piece.col])
    update_piece_location(piece, move)
  end
  
  def jump_piece(piece, move)
    clear_space([piece.row, piece.col])
    distance = [move[0] - piece.row, move[1] - piece.col]
    jumped_coord = jumped_coord([piece.row, piece.col], distance)
    clear_space(jumped_coord)
    update_piece_location(piece, move)
  end
  
  def valid_jump?(start, offset, color)
    jumped_coord = jumped_coord(start, offset)
    return false if empty?(jumped_coord) || !valid_coord?(jumped_coord)
    jumped_piece = get_piece(jumped_coord)
    jumped_piece.color != color
  end
end