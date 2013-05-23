require 'pp'
require 'colorize'
require 'yaml'

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
    p "in play"
    until game_over?
      @board.display
      
      prompt_choose_piece
      piece_loc = @players[@turn].get_coord
      next if not valid_piece_choice?(piece_loc)
      piece = @board.get_piece(piece_loc)
      
      prompt_move_sequence
      move_sequence = @players[@turn].get_coords
      next if not piece.valid_move_sequence?(move_sequence)
      

      piece.perform_moves(move_sequence)
      piece.promote if piece.row == 0 || piece.row == 7
      
      swap_turns
    end
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
    swap_turns
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


class Board
  attr_reader :board
  
  def initialize
    @board = generate_board
  end
    
  def display
    print "   "
    8.times { |n| print " #{n}  "}
    print "\n  "
    33.times { print '-'}
    puts
    8.times do |row|
      print "#{row} |"
      8.times do |col|
        color = @board[row][col].color unless @board[row][col].nil?
        print @board[row][col].class == Piece ? " #{"O".send(color)} |" : "   |"
      end
      print "\n  "
      33.times { print '-'}
      print "\n"
    end
  end
  
  def get_piece(coord)
    return nil if coord.length != 2
    row, col = coord
    @board[row][col] #returns nil if empty
  end
  
  def get_pieces(color)
    pieces = []
    8.times do |row|
      8.times do |col|
        piece = get_piece([row, col])
        pieces << piece if !piece.nil? && piece.color == color
      end
    end
    pieces
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
      8.times { |col| row[col] = Piece.new([rindex, col], color, self) unless col.even? }
    else
      8.times { |col| row[col] = Piece.new([rindex, col], color, self) unless col.odd? }
    end
  end
end


class Piece
  attr_accessor :row, :col
  attr_reader :color
  DELTAS = { :slide_move => [[1, -1], [1, 1], [-1, -1], [-1, 1]],
             :jump_move => [[2, -2], [2, 2], [-2, -2], [-2, 2]]
            }
            
  def initialize(location, color, board)
    @board = board
    @row, @col = location
    @color = color
    @king = false
  end
  
  def promote
    @king = true
  end
  
  def has_valid_moves?
    !slide_moves.empty? || jump_move_available?
  end
  
  def slide_moves
    possible_moves = []
    if jump_move_available?
      possible_moves
    else
      deltas = @king ? DELTAS[:slide_move] : filter_by_color(DELTAS[:slide_move])
      deltas.each do |drow, dcol|
        move = [@row + drow, @col + dcol]
        possible_moves << move if @board.empty?(move) && @board.valid_coord?(move)
      end
      possible_moves
    end
  end
  
  def jump_moves
    possible_moves = []
    deltas = @king ? DELTAS[:jump_move] : filter_by_color(DELTAS[:jump_move])
    deltas.each do |drow, dcol|
      if @board.valid_jump?([@row, @col], [drow, dcol], color)
        move = [@row + drow, @col + dcol]
        possible_moves << move if @board.empty?(move) && @board.valid_coord?(move)
      end
    end
    possible_moves
  end
  
  def perform_slide(move)
    if slide_moves.include?(move)
      @board.slide_piece(self, move)
    else
      puts "Not a valid move."
      raise InvalidMoveError
    end
  end

  def perform_jump(move)
    if jump_moves.include?(move)
      @board.jump_piece(self, move)
    else
      raise InvalidMoveError
    end
  end
  
  def perform_moves!(move_sequence)
    #if a move fails, InvalidMoveError, don't try to restore
    move_sequence.each do |move|
      p slide_moves
      if slide_moves.include?(move)
        p "in the if"
        perform_slide(move)
      elsif jump_moves.include?(move)
        perform_jump(move)
      else
        raise InvalidMoveError
      end
    end
  end
  
  def perform_moves(move_sequence)
    #checks valid_move_seq and either calls perform_moves! or InvalidMoveError
    perform_moves!(move_sequence) if valid_move_sequence?(move_sequence)
  end
  
  def valid_move_sequence?(move_sequence)
    #calls perorm_moves! on a duped Piece/Board, using begin/rescue/else
    clone = YAML.load(self.to_yaml)
    begin
      
      clone.perform_moves!(move_sequence)
    rescue InvalidMoveError => e
    end
    e ? false : true
  end
  

  def jump_move_available?
    @board.get_pieces(color).any? do |piece|
      piece.jump_moves != []
    end
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
  
  def get_coord
    gets.chomp.scan(/\d/).map(&:to_i)
  end
  
  def get_coords
    gets.chomp.scan(/\d\D\d|\d\d/).map { |pair| pair.split('').map(&:to_i) }
  end
end


if __FILE__ == $PROGRAM_NAME
  c = Checkers.new
  c.play

end