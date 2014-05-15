# NOTES
# raise error if start_pos is empty!!!
#

require './board'
 
class Game
  attr_reader :board
  
  def initialize(board = Board.new)
    @board = board
  end
  
  def play
    player = :black
    
    until won?
      prompt(player)
      
      turn = turn == :black ? :white : :black
    end
  end
  
  def prompt(color)
    puts "What's the position of the piece you want to move?"
    start_pos = parse(gets.chomp.strip)
  end
  
  def parse(input)
    input.split("-").map do |coord|
      coord.strip.split(",").map { |x| x.strip.to_i }
    end
  end
  
  def won?
    color_check = board.pieces[0].color
    board.pieces.all? { |piece| piece.color == color_check }
  end
end