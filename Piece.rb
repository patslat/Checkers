require './Board.rb'

class Piece
  attr_accessor :row, :col
  attr_reader :color, :king
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
    return [] if jump_move_available?
    
    deltas(:slide_move).each_with_object([]) do |(drow, dcol), arr|
      move = [@row + drow, @col + dcol]
      arr << move if @board.empty?(move) && @board.valid_coord?(move)
    end
  end
  
  def jump_moves
    deltas(:jump_move).each_with_object([]) do |(drow, dcol), arr|
      move = [@row + drow, @col + dcol]
      if (@board.valid_jump?([@row, @col], [drow, dcol], color) && 
          @board.empty?(move) &&
          @board.valid_coord?(move))
            arr << move 
      end
    end
  end
  
  def perform_slide(move)
    if slide_moves.include?(move)
      @board.slide_piece(self, move)
    else
      raise InvalidMoveError
    end
  end

  def perform_jump(move)
    raise InvalidMoveError unless jump_moves.include?(move)
    @board.jump_piece(self, move)
  end
  
  def perform_moves!(move_sequence)
    move_sequence.each do |move|
      if slide_moves.include?(move)
        perform_slide(move)
      elsif jump_moves.include?(move)
        perform_jump(move)
      else
        raise InvalidMoveError
      end
    end
  end
  
  def perform_moves(move_sequence)
    perform_moves!(move_sequence) if valid_move_sequence?(move_sequence)
  end
  
  def valid_move_sequence?(move_sequence)
    clone = YAML.load(self.to_yaml)
    begin 
      clone.perform_moves!(move_sequence)
    rescue InvalidMoveError => e
    end
    !e
  end
  
  private
  def deltas(move)
    @king ? DELTAS[move] : filter_by_color(DELTAS[move])
  end
  
  def jump_move_available?
    @board.get_pieces(color).any? { |piece| piece.jump_moves != [] } # #empty? won't work?!?!
  end

  def filter_by_color(deltas)
    return deltas.select { |row, col| row > 0 } if color == :red
    return deltas.select { |row, col| row < 0 } if color == :black
  end
end