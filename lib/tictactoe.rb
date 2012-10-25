require "color_text"

class Tictactoe
  
  def initialize
    @moves = (0..8).to_a
    @computer_move = 4
    @playing = true
    @message = "Please enter your move".blue
    @continue = true
  end

  def play_game
    play_tictactoe
    if play_until_win
      who_won = winner.first == 'X' ? 'Computer' : 'You'
      puts '********************'
      display_board
      puts "#{who_won} Won".neon
    elsif play_until_draw
      puts '********************'
      display_board
      puts "It's a draw".neon
    end
  end
  
  private
  
    def play_tictactoe
      display_board
      @start_game = interactive
      while @continue
        print "\e[2J\e[f" # clear screen
        case @start_game
        when 'y'
          display_board
          competitor_plays
          break if !@continue
          computer_plays
          break if !@continue
        when 'q'
          break
        when 'n'
          computer_plays
          display_board
          break if !@continue
          competitor_plays
          break if !@continue
        else
          display_board
          puts 'Please enter appropriate options'.red
          interactive
        end
      end
    end
  
    def interactive
      puts 'Do you want to play first? enter y/n and q to quit'.purple
      @start_game = gets.chomp
    end
  
    def computer_plays
      if @playing
        computer_moves
        @continue = continue_playing
      end
    end
  
    def competitor_plays
      if @continue
        puts @message
        move = gets.chomp
        play(move)
        @continue = continue_playing
      end
    end
  
    def continue_playing
      if (play_until_win || play_until_draw)
        false
      else
        true
      end
    end
  
    def play(move)
      if move.size > 1
        @playing = false
        @message = "Please enter appropriate move".red
        puts @message
      elsif @moves.values_at(move.to_i).first == "X" || @moves.values_at(move.to_i).first == "O"
        @playing = false
        @message = "Please choose another move, it's already taken".red
        puts @message
      elsif !is_numeric(move)
        @playing = false
        @message = "Please enter correct move".red
        puts @message
      else
        position = @moves.index(move.to_i)
        @playing = true
        @message = "Please enter your move".blue
        @moves[position] = "O"
      end
    end
  
    def computer_moves
      temp_moves = @moves.clone
      temp_moves.delete("O")
      temp_moves.delete("X")
      if temp_moves.size == @moves.size
        @moves[4] = "X"
      elsif computer_best_move
        @computer_move = computer_best_move
        @moves[computer_best_move] = "X"
      elsif competitor_best_move
        @computer_move = competitor_best_move
        @moves[competitor_best_move] = "X"
      else
        indexes = temp_moves.inject([]) do |result, element|
          result << @moves.index(element)
          result
        end
        position_index = Random.new.rand(0...indexes.size)
        values_position = indexes.values_at(position_index).first
        @computer_move = values_position
        @moves[values_position] = "X"
      end
    end
  
    def display_board
      board = ""
      @moves.each_with_index do |move, index|
        case move
        when 'X'
          color_moves = "#{move}".purple
        when 'O'
          color_moves = "#{move}".yellow
        else
          color_moves = "#{move}"
        end
        new_line = (index == 3 || index == 6) ? "\n" : ""
        board += new_line + color_moves
        board += "|"
      end
      puts "#{board}"
    end
  
    def winner
      get_values.detect do |value|
        value.one?
      end
    end
  
    def play_until_win
      if winner
        true
      else
        false
      end
    end
  
    def play_until_draw
      unmoved = @moves.select do |move|
        (0..10).include?(move)
      end
      !(unmoved.any?)
    end
  
    def get_values
      score_values.inject([]) do |result, v|
        result << @moves.values_at(v[0], v[1], v[2]).uniq
        result
      end
    end
  
    def best_move(check_moves_of, replace_with)
      score_values.each do |v|
        result  = @moves.values_at(v[0], v[1], v[2])
        if result.include?("#{check_moves_of}") && result.count("#{check_moves_of}") == 2
          result.delete("#{check_moves_of}")
          if result.first == "#{replace_with}"
            @move = nil
          else
            @move = result.first
          end
        end
      end
      @move
    end
  
    def computer_best_move
      best_move('X', 'O')
    end
  
    def competitor_best_move
      best_move('O', 'X')
    end
  
    def score_values
      rows = board
      columns = rows.transpose
      columns.each do |column|
        rows.push(column)
      end
      rows.push(generate_diagonal(board))
      rows.push(generate_diagonal(board.reverse))
      rows
    end
  
    def generate_diagonal(board)
      diagonals = []
      board.each_with_index do |element, index|
        diagonals << element[index]
      end
      diagonals
    end
  
    def board
      (0..8).each_slice(3).to_a
    end
  
    def is_numeric(move)
      move.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
    end
end