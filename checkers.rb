require 'colorize'
require 'yaml'
require './HumanPlayer.rb'
require './Board.rb'
require './Piece.rb'

class InvalidMoveError < StandardError
end

class Checkers
  def initialize
    @board = Board.new
    @players = {
      :black => HumanPlayer.new(:black),
      :red => HumanPlayer.new(:red)
    }
    @turn = :black
  end
  
  def play
    until game_over?
      @board.display
      
      prompt_choose_piece
      piece_loc = @players[@turn].get_coord
      next if not valid_piece_choice?(piece_loc)
      piece = @board.get_piece(piece_loc)
      
      prompt_move_sequence
      move_sequence = @players[@turn].get_coords
      next if not piece.valid_move_sequence?(move_sequence)

      piece.perform_moves!(move_sequence)
      piece.promote if piece.row == 0 || piece.row == 7
      
      swap_turns
    end
    swap_turns
    announce_winner
  end
  
  private
  def valid_piece_choice?(coord)
    if (piece = @board.get_piece(coord)).nil? || !@board.valid_coord?(coord)
      false
    else
      piece.color == @turn
    end
  end
  
  def announce_winner
    "#{@turn.to_s.capitalize} wins!"
  end
  
  def game_over?
    @board.get_pieces(@turn).none? do |piece|
      piece.has_valid_moves?
    end
  end
  
  def swap_turns
    @turn = @turn == :black ? :red : :black
  end
  
  def prompt_choose_piece
    puts "#{@turn.to_s.capitalize}, please enter the coordinates of the piece you would like to move: "
  end
  
  def prompt_move_sequence
    puts "Please enter the coordinates of the location(s) you would like to move the piece to: "
  end
end


if __FILE__ == $PROGRAM_NAME
  c = Checkers.new
  c.play
end