require 'pp'
require 'colorize'

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
      piece = @board.get_piece([2,1])
      
      piece.perform_slide([3, 0], @board)
      piece = @board.get_piece([3,0])
      piece.perform_slide([4, 1], @board)
      piece = @board.get_piece([5,0])
      piece.perform_jump( [3,2], @board)
      @board.display
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
  
  def slide_piece(piece, move)
    start_row = piece.row
    start_col =  piece.col
    new_row, new_col = move
    @board[start_row][start_col] = nil
    piece.row = new_row
    piece.col = new_col
    @board[new_row][new_col] = piece
  end
  
  def jump_piece(piece, move)
    start_row = piece.row
    start_col = piece.col
    new_row, new_col = move
    @board[start_row][start_col] = nil
    jumped_coord = jumped_coord([start_row, start_col], [new_row - start_row, new_col - start_col])
    jumped_row, jumped_col = jumped_coord
    @board[jumped_row][jumped_col] = nil
    piece.row = new_row
    piece.col = new_col
    @board[new_row][new_col] = piece
  end
  
  def empty?(coord)
    row, col = coord
    @board[row][col].nil?
  end
  
  def valid_coord?(coord)
    row, col = coord
    (0..7).include?(row) && (0..7).include?(col)
  end
  
  def valid_jump?(start, offset, color)
    jumped_coord = jumped_coord(start, offset)
    return false if empty?(jumped_coord)
    jumped_piece = get_piece(jumped_coord)
    jumped_piece.color != color
  end
  
  def jumped_coord(start, offset)
    row, col = start
    drow, dcol = offset.map { |n| n / 2}
    jumped_coord = [row + drow, col + dcol]
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
  attr_accessor :row, :col
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
      move = [@row + drow, @col + dcol]
      possible_moves << move if board.empty?(move) && board.valid_coord?(move)
    end
    possible_moves
  end
  
  def jump_moves(board)
    possible_moves = []
    deltas = @king ? DELTAS[:jump_move] : filter_by_color(DELTAS[:jump_move])
    deltas.each do |drow, dcol|
      if board.valid_jump?([@row, @col], [drow, dcol], color)
        move = [@row + drow, @col + dcol]
        possible_moves << move if board.empty?(move) && board.valid_coord?(move)
      end
    end
    possible_moves
  end
  
  def perform_slide(move, board)
    if slide_moves(board).include?(move)
      board.slide_piece(self, move)
    else
      raise InvalidMoveError
      puts "Not a valid move."
    end
  end

  def perform_jump(move, board)
    if jump_moves(board).include?(move)
      board.jump_piece(self, move)
    else
      raise InvalidMoveError
      puts "Not a valid move."
    end
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
    return deltas.select { |row, col| row > 0 } if color == :red
    return deltas.select { |row, col| row < 0 } if color == :black
  end
  
end

class HumanPlayer
  def initialize(color)
    @color = color
  end
  
  
end