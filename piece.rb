class Piece
  attr_accessor :king, :pos
  
  attr_reader :color, :board
  
  def initialize(board, pos, color)
    @board = board # BOARD OBJECT!!!
    @pos = pos
    @color = color
    @king = false
    
    @board[pos] = self
  end
  
  def to_s
    self.color == :black ? "⚫" : "⚪"
  end
  
  def possible_spaces
    x, y = self.pos
    
    move_diffs.map { |dir| [x + dir[0], y + dir[1]] }
  end
  
  def valid_slide_spaces
    possible_spaces.select { |space| self.board.empty?(space) }
  end
  
  def valid_jump_spaces
    possible_spaces.select do |space| 
      !self.board.empty?(space) && self.board.has_enemy?(space, self.color)
  end
  
  def perform_slide(start_pos, end_pos)
    x, y = start_pos
    
    good_to_go = valid_spaces(start_pos).include?(end_pos)
    
    if good_to_go && self.board.empty?(end_pos)
      self.pos = end_pos
      self.board[end_pos] = self
      self.board[start_pos] = nil
    end
    
    good_to_go
  end
  
  def perform_jump(start_pos, end_pos)
    x, y = start_pos
    
    good_to_go = valid_spaces(start_pos).

    direction = move_diffs.find do |dir|
      space = [x + dir[0], y + dir[1]]
      
      board.empty?(end_pos) &&
      !board.empty?(space) && 
      board[space].color != color &&
      end_pos == [space[0] + dir[0], space[1] + dir[1]]
    end
    
    if direction
      conquered_space = [x + direction[0], y + direction[1]]
      
      self.pos = end_pos
      board[end_pos] = self
      board[conquered_space] = nil
      board[start_pos] = nil
      return true
    end
    
    false  
  end
  
  def perform_mega_jump(start_pos, end_pos)
    x, y = start_pos

    direction = move_diffs.find do |dir|
      space = [x + dir[0], y + dir[1]]
      space_to_conquer = [x + dir[0] * 2, y + dir[1] * 2]
      other_space = [x + dir[0] * 3, y + dir[1] * 3]

      board.empty?(space) &&
      !board.empty?(space_to_conquer) &&
      board[space_to_conquer].color != color &&
      board.empty?(other_space) &&
      board.empty?(end_pos)
    end
    
    if direction
      conquered_space = [x + direction[0] * 2, y + direction[1] * 2]
      
      self.pos = end_pos
      board[end_pos] = self
      board[conquered_space] = nil
      board[start_pos] = nil
      return true
    end
    
    false
  end
  
  def move_diffs
    x_multiplier = color == :white ? 1 : -1
    moves = [[1, -1], [1, 1]]
    moves += [[-1, -1], [-1, 1]] if @king
    
    moves.map { |x, y| [x * x_multiplier, y] }
  end
  
  def promote?
    # when piece reaches back row, check to promote
  end
end