require 'pp'
require 'colorize'

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
  end
  
end


class Board
  attr_reader :board
  
  def initialize
    @board = generate_board
  end
    
  def display
    8.times do |row|
      8.times do |col|
        color = @board[row][col].color unless @board[row][col].nil?
        print @board[row][col].class == Piece ? "| #{"O".send(color)} |" : "|   |"
      end
      print "\n"
      40.times { print '-'}
      print "\n"
    end
  end
  
  def get_piece(coord)
    row, col = coord
    @board[row][col] #returns nil if empty
  end
  
  def empty?(coord)
    row, col = coord
    @board[row][col].nil?
  end
  
  def valid_coord?(coord)
    row, col = coord
    
  end
  
  private
  def generate_board
    populate_board (Array.new(8) { Array.new(8) })
  end
  
  def populate_board(board)
    8.times do |rindex|
      populate_row(board[rindex], :red, rindex) if rindex < 3
      populate_row(board[rindex], :black, rindex) if rindex > 4
    end
    board
  end
  
  def populate_row(row, color, rindex)
    if rindex.even?
      8.times { |col| row[col] = Piece.new([rindex, col], color) unless col.even? }
    else
      8.times { |col| row[col] = Piece.new([rindex, col], color) unless col.odd? }
    end
  end
end


class Piece
  attr_reader :color
  DELTAS = { :slide_move => [[1, -1], [1, 1], [-1, -1], [-1, 1]],
             :jump_move => [[2, -2], [2, 2], [-2, -2], [-2, 2]]
            }
            
  def initialize(location, color)
    @row, @col = location
    @color = color
    @king = false
  end
  
  def slide_moves(board)
    possible_moves = []
    deltas = @king ? DELTAS[:slide_move] : filter_by_color(DELTAS[:slide_move])
    deltas.each do |drow, dcol|
      p drow
      p dcol
      move = [@row + drow, @col + dcol]
      possible_moves << move if board.empty?(move) && board.valid_coord?(move)
    end
    possible_moves
  end
  
  def jump_moves(board)
    possible_moves = []
    
  end
  
  def perform_moves!(move_sequence)
    #if a move fails, InvalidMoveError, don't try to restore
  end
  
  def perform_moves(move_sequence)
    #checks valid_move_seq and either calls perform_moves! or InvalidMoveError
  end
  
  def valid_move_sequence?(move_sequence)
    #calls perorm_moves! on a duped Piece/Board, using begin/rescue/else
  end
  
  private
  def filter_by_color(deltas)
    p deltas
    return deltas.select { |row, col| row > 0 } if color == :red
    return deltas.select { |row, col| row < 0 } if color == :black
  end
  
end

class HumanPlayer
  def initialize(color)
    @color = color
  end
  
  
end