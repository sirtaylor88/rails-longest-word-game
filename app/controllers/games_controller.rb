require 'nokogiri'
require 'open-uri'
require 'json'

class GamesController < ApplicationController
  before_action :set_session_values
  def new
    @grid = []
    10.times { @grid << ('A'..'Z').to_a.sample }
    cond = %w[A E I O U Y].map { |vowels| @grid.include?(vowels) }.any?
    @grid[(0..@grid.size - 1).to_a.sample] = %w[A E I O U Y].sample unless cond
  end

  def score
    @letters = params[:grid].chars
    @chars = params[:input].upcase.chars
    check_condition
  end

  private

  def set_session_values
    reset_session
    session[:score] ||= 0
  end

  def hashed(word)
    word_hash = {}
    ('A'..'Z').to_a.each do |letter|
      word_hash[letter] = word.count(letter)
    end
    word_hash
  end

  def valid?(word)
    url = "https://wagon-dictionary.herokuapp.com/#{word}"
    response = open(url).read
    doc = JSON.parse(response)
    doc['found']
  end

  def congratulate
    @message = "Congratulations! #{@chars.join} is a valid English word!"
    @message += "You gain #{@chars.size} points"
    session[:score] += @chars.size
  end

  def invalid_english
    @message = "Sorry but #{@chars.join} does not seem to be a valid English word"
  end

  def invalid_word
    @message = "Sorry but #{@chars.join} can't be built out of
    #{@letters.join(', ').strip}"
  end

  def check_condition
    cond = hashed(@chars).map { |k, v| v <= hashed(@letters)[k] }.all?
    if cond && valid?(params[:input])
      congratulate
    else
      cond ? invalid_english : invalid_word
    end
  end
end
