require './piece.rb'
require 'colorize'

class Board
  attr_reader :grid
  
  def self.empty_grid
    Array.new(8) { Array.new(8) }
  end
  
  def initialize(grid = Board.empty_grid)
    @grid = grid # ARRAY
    # populate
  end
  
  def populate
    odd_cols = [1, 3, 5, 7]
    even_cols = [0, 2, 4, 6]
    
    odd_cols.each do |col|
      Piece.new(self, [0, col], :white)
      Piece.new(self, [2, col], :white)
      Piece.new(self, [6, col], :black)
    end
    
    even_cols.each do |col|
      Piece.new(self, [1, col], :white)
      Piece.new(self, [5, col], :black)
      Piece.new(self, [7, col], :black)
    end
  end
  
  def [](pos)
    i, j = pos
    grid[i][j]
  end
  
  def []=(pos, piece)
    i, j = pos
    grid[i][j] = piece
  end
  
  def empty?(pos)
    self[pos].nil?
  end
  
  def has_enemy?(space, my_color)
    !self.empty?(space) && self[space].color != my_color
  end
  
  def dup
    board_dup = Board.new
    
    grid.flatten.compact.each do |piece| 
      Piece.new(board_dup, piece.pos.dup, piece.color)
    end
    
    board_dup
  end
  
  def display
    alternate = 1
    
    grid.each do |row|
      row.each do |piece|
        bg_color = alternate == 1 ? :red : :green
        
        to_print = piece.nil? ? "   " : " #{piece} "
        print to_print.colorize(:background => bg_color)
        
        alternate = alternate == 1 ? 0 : 1
      end
      puts
      
      alternate = alternate == 1 ? 0 : 1      
    end
  end
end