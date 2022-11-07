require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    # get grid size
    grid_size = rand(4..10)
    @letters = grid_size.times.map { ('A'..'Z').to_a[rand(0...26)] }.unshift(%w[A E I O U][rand(0...5)]) # at least 1 vovel
    session[:score] = 0 if session[:score].nil? || params[:reset]
  end

  def score
    url = "https://wagon-dictionary.herokuapp.com/#{params[:attempt]}"
    word_serialized = URI.open(url).read
    word = JSON.parse(word_serialized)
    if !word["found"]
      @message = "Sorry but #{params[:attempt].upcase} does not seem to be a valid English word"
    elsif !check_grid(params[:grid].chars, word["word"].chars)
      @message = "Sorry but #{params[:attempt].upcase} can't be built out of #{params[:grid].split.join}"
    else
      @message = "Well Done!"
      @score = 30 - (Time.now - Time.parse(params[:start_time])) + params[:attempt].size
      session[:score] += @score
    end
    @grand_score = session[:score]
  end

  private

  def check_grid(grid, word)
    in_the_grid = word.all? { |letter| grid.include?(letter.upcase) }
    no_overuse = false
    word.each do |letter|
      if grid.include?(letter.upcase)
        grid_index = grid.find_index { |char| char == letter.upcase }
        grid.delete_at(grid_index) unless grid_index.nil?
        letter.gsub!(letter, "")
      end
    end
    no_overuse = true if word.join == ""
    in_the_grid && no_overuse
  end
end
