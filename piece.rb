class InvalidMoveError < StandardError
end

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
  
  def dir(start_pos, end_pos)
    # write method for determining direction
  end
  
  def to_s
    if self.king
      self.color == :black ? "♛" : "♛".colorize(:white)
    else
      self.color == :black ? "❤" : "❤".colorize(:white)
    end
  end
  
  def dup
    Piece.new(self.board.dup, self.pos.dup, self.color)
  end
  
  def perform_moves(*moves)
    raise InvalidMoveError unless valid_move_seq?(*moves)
    
    perform_moves!(*moves)
    self.king = true if promote?
  end
  
  def valid_move_seq?(*moves)
    begin
      self.dup.perform_moves!(*moves)
    rescue
      return false
    end
    
    true
  end
  
  def perform_moves!(*moves)
    if moves.count == 1
      checks_out = perform_slide(self.pos, moves[0]) || 
        perform_jump(self.pos, moves[0]) ||
        perform_mega_jump(self.pos, moves[0])
    else
      start_pos = self.pos
      
      moves.each do |move|
        checks_out = perform_jump(start_pos, move)
        start_pos = move
      end
    end
    
    raise "Invalid move!" unless checks_out
  end
  
  def possible_spaces
    x, y = self.pos

    move_diffs.map { |dir| [x + dir[0], y + dir[1]] }
  end
  
  def on_the_board?(coord)
    coord.all? { |x| x.between?(0, 7) }
  end
  
  def valid_slide_spaces
    possible_spaces.select do |space| 
      self.board.empty?(space) && on_the_board?(space)
    end
  end
  
  def valid_jump_spaces(start_pos = self.pos)
    # evaluates the spaces one space away where enemy resides
    # returns Piece's new possible spaces after jumping over enemy
    
    enemy_spaces = possible_spaces.select do |space| 
      !self.board.empty?(space) && 
      self.board.has_enemy?(space, self.color) &&
      on_the_board?(space)
    end
    
    jump_to_spaces = []
    
    enemy_spaces.each do |x, y|
      dir_x, dir_y = x - self.pos[0], y - self.pos[1]
      jump_to_space = [x + dir_x, y + dir_y]
      
      jump_to_spaces << jump_to_space if self.board.empty?(jump_to_space)
    end
    
    jump_to_spaces
  end
  
  def valid_mega_jump_spaces
    one_space_aways = possible_spaces.select do |space| 
      self.board.empty?(space) && on_the_board?(space)
    end
    
    mega_jump_spaces = []
    
    one_space_aways.each do |space|
      x, y = space
      dir_x, dir_y = x - self.pos[0], y - self.pos[1]
      enemy_space = [x + dir_x, y + dir_y]
      
      if self.board.has_enemy?(enemy_space, self.color)
        next_space = [enemy_space[0] + dir_x, enemy_space[1] + dir_y]
        
        if self.board.empty?(next_space)
          final_space = [next_space[0] + dir_x, next_space[1] + dir_y]
          mega_jump_spaces << final_space if self.board.empty?(final_space)
        end
      end
    end
    
    mega_jump_spaces
  end
  
  def perform_slide(start_pos, end_pos)    
    if valid_slide_spaces.include?(end_pos)
      self.pos = end_pos
      self.board[end_pos] = self
      self.board[start_pos] = nil
      return true
    end
    
    false
  end
  
  def perform_jump(start_pos, end_pos)
    if valid_jump_spaces.include?(end_pos)
      dir_x = (end_pos[0] - start_pos[0]) / 2
      dir_y = (end_pos[1] - start_pos[1]) / 2
      conquered_space = [start_pos[0] + dir_x, start_pos[1] + dir_y]
      
      self.pos = end_pos
      board[end_pos] = self
      board[conquered_space] = nil
      board[start_pos] = nil
      return true
    end
    
    false  
  end
  
  def perform_mega_jump(start_pos, end_pos)
    if valid_mega_jump_spaces.include?(end_pos)
      dir_x = (end_pos[0] - start_pos[0]) / 2
      dir_y = (end_pos[1] - start_pos[1]) / 2
      conquered_space = [start_pos[0] + dir_x, start_pos[1] + dir_y]
      
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
    (self.color == :white && self.pos[0] == 7) ||
    (self.color == :black && self.pos[0] == 0)
  end
end