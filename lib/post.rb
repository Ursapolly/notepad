# encoding: utf-8

require 'sqlite3'

class Post
  SQLITE_DB_FILE = './notepad.db3'.freeze

  def self.post_types
    { 'Memo' => Memo, 'Link' => Link, 'Task' => Task }
  end

  def self.create(type)
    post_types[type].new
  end

  def initialize
    @created_at = Time.now
    @text = []
  end

  def self.find(limit, type, id)
    db = SQLite3::Database.open(SQLITE_DB_FILE)

    if !id.nil?
      db.results_as_hash = true
      result = db.execute('SELECT * FROM posts WHERE rowid = ?', id)

      db.close

      if result.empty?
        puts "Id #{id} не найден в базе"
        return nil
      else
        result = result[0]
        post = create(result['type'])
        post.load_data(result)
        post
      end
    else
      db.results_as_hash = false
      query = 'SELECT rowid, * FROM posts '
      query += 'WHERE type = :type ' unless type.nil?
      query += 'ORDER by rowid DESC '
      query += 'LIMIT :limit ' unless limit.nil?
      statement = db.prepare query
      statement.bind_param('type', type) unless type.nil?
      statement.bind_param('limit', limit) unless limit.nil?
      result = statement.execute!

      statement.close

      db.close

      result
    end
  end

  def read_from_console
    # todo
  end

  def to_strings
    # todo
  end

  def load_data(data_hash)
    @created_at = Time.parse(data_hash['created_at'])
    @text = data_hash['text']
  end

  def to_db_hash
    {
      'type' => self.class.name,
      'created_at' => @created_at.to_s
    }
  end

  def save_to_db
    db = SQLite3::Database.open(SQLITE_DB_FILE)
    db.results_as_hash = true
    post_hash = to_db_hash
    db.execute(
        'INSERT INTO posts (' +
        post_hash.keys.join(', ') +
        ") VALUES (#{('?,' * post_hash.size).chomp(',')})",
        post_hash.values
    )
    insert_row_id = db.last_insert_row_id
    db.close
    insert_row_id
  end

  def save
    file = File.new(file_path, 'w:UTF-8')
    to_strings.each { |string| file.puts(string) }
    file.close
  end

  def file_path
    current_path = File.dirname(__FILE__)
    file_name = @created_at.strftime('%Y-%m-%d_%H-%M-%S')
    "#{current_path}/#{self.class.name}_#{file_name}.txt"
  end
end
