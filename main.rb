# encoding: utf-8

require_relative 'post'
require_relative 'memo'
require_relative 'link'
require_relative 'task'


puts 'Привет, я твой блокнот!\n\nЧто хочешь записать?'

choices = Post.post_types.keys

choice = -1

until choice >= 0 && choice < choices.size
  choices.each_with_index do |type, index|
    puts "\t#{index}. #{type}"
  end

  choice = gets.to_i
end

entry = Post.create(choices[choice])

entry.read_from_console

rowid = entry.save_to_db

puts "Запись сохранена, id – #{rowid}"