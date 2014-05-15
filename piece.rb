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
    self.color == :black ? "⚫" : "⚪"
  end
  
  def possible_spaces(n = 1)
    x, y = self.pos
    
    # n = number of spaces away you want to evaluate
    move_diffs.map { |dir| [x + dir[0] * n, y + dir[1] * n] }
  end
  
  def valid_slide_spaces
    possible_spaces.select { |space| self.board.empty?(space) }
  end
  
  def valid_jump_spaces(start_pos = self.pos)
    # evaluates the spaces one space away where enemy resides
    # returns Piece's new possible spaces after jumping over enemy
    
    enemy_spaces = possible_spaces.select do |space| 
      !self.board.empty?(space) && self.board.has_enemy?(space, self.color)
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
    one_space_aways = possible_spaces.select { |space| self.board.empty?(space) }
    
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
    # when piece reaches back row, check to promote
  end
end