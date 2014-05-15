# NOTES
# raise error if start_pos is empty!!!
#
require 'pry'
require './board.rb'
require './piece.rb'

class WrongPieceError < StandardError
end 
 
class Game
  attr_reader :board
  
  def initialize(board = Board.new)
    @board = board
    # @board.populate
  end
  
  def play
    player = :black
    
    until won?
      begin
        self.board.display
        move_seq = prompt(player)
        
        raise WrongPieceError if @board[move_seq[0]].color != player
        
        start_pos = move_seq.shift
        *moves = move_seq
        self.board[start_pos].perform_moves(*moves)
        
      rescue WrongPieceError => e
        puts "That's not your piece!"
        retry
      rescue InvalidMoveError => e
        puts "You can't move there :("
        retry
      end

      player = player == :black ? :white : :black
    end
    
    puts player.to_s.capitalize + " wins!"
  end
  
  def prompt(color)
    puts "What's the position of the piece you want to move?"
    start_pos = parse(gets.chomp.strip)
    
    puts "Where would you like to move him?"
    move_seq = parse(gets.chomp.strip)
    
    start_pos + move_seq
  end
  
  def parse(input)
    input.split("-").map do |coord|
      coord.strip.split(",").map { |x| x.strip.to_i }
    end
  end
  
  def won?
    color_check = self.board.pieces[0].color
    self.board.pieces.all? { |piece| piece.color == color_check }
  end
end