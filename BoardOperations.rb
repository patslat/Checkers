module BoardOperations

  def display
    print "   "
    8.times { |n| print " #{n}  "}
    print "\n  "
    33.times { print '-'}
    puts
    8.times do |row|
      print "#{row} |"
      8.times do |col|
        if !@board[row][col].nil?
          color = @board[row][col].color
          if @board[row][col].king 
            print " #{"\u{265A}".send(color)} |"
          else
            print " #{"\u{25CF}".send(color)} |"  
          end
        else
          print "   |"
        end
      end
      print "\n  "
      33.times { print '-'}
      print "\n"
    end
  end
  
  def get_piece(coord)
    return nil if !valid_coord?(coord)
    row, col = coord
    @board[row][col] #returns nil if empty
  end
  
  def get_pieces(color)
    pieces = []
    each_tile { |piece| pieces << piece if !piece.nil? && piece.color == color }
    pieces
  end
  
  def empty?(coord)
    get_piece(coord).nil?
  end
  
  def valid_coord?(coord)
    row, col = coord
    (0..7).include?(row) && (0..7).include?(col)
  end

  
  private
  
  def each_tile(&blk)
    8.times do |row|
      8.times do |col|
        yield @board[row][col]
      end
    end
  end
  
  def update_piece_location(piece, new_loc)
    row, col = new_loc
    piece.row = row
    piece.col = col
    set_piece(piece, new_loc)
  end
  
  def clear_space(coord)
    row, col = coord
    @board[row][col] = nil
  end
  
  def set_piece(piece, coord)
    row, col = coord
    @board[row][col] = piece
  end
  
  def jumped_coord(start, offset)
    row, col = start
    drow, dcol = offset.map { |n| n / 2}
    jumped_coord = [row + drow, col + dcol]
  end

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