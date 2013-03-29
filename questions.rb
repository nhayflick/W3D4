require 'singleton'
require 'sqlite3'

class QuestionsDatabase < SQLite3::Database
  include Singleton
  def initialize
    super("questions.db")
    self.results_as_hash = true
    self.type_translation = true
  end

  def get_users

  end
end

class User
  def initialize(fname, lname, is_instructor, user_id = nil)
    @user_id    = user_id
    @fname = fname
    @lname = lname
    @is_instructor = is_instructor
  end

  def self.find(id)
    data = ( QuestionsDatabase.instance.execute (
    "SELECT * FROM users WHERE user_id = #{id}" ) )[0]
    User.new(
    data['first_name'],
    data['last_name'],
    data['is_instructor'],
    data['user_id']
    )
  end

  def asked_questions
    questions = (QuestionsDatabase.instance.execute("SELECT * FROM questions JOIN users ON author=user_id WHERE author = #{@user_id}"))
    questions.map {|question| Question.build_question(question) }
  end

  def average_karma
    sql = <<-SQL
      SELECT (COUNT(ql.user_id))/(COUNT (DISTINCT ql.question_id)) FROM questions q JOIN question_likes ql    ON q.question_id = ql.question_id WHERE q.author = ?;
    SQL
    QuestionsDatabase.instance.execute(sql, @user_id)[0].values.first
  end

  def like_question(question_id)
    Like.create(@user_id, question_id)
  end

  def unlike_question(question_id)
    Like.delete(@user_id, question_id)
  end

  def most_karma
    sql = <<-SQL
      SELECT count(ql.user_id) FROM questions q JOin question_likes ql ON q.question_id = ql.question_id          WHERE q.author = ?
      GROUP BY ql.question_id
      ORDER BY count(ql.user_id) desc
      ;
    SQL
    QuestionsDatabase.instance.execute(sql, @user_id)[0].values.first
  end

  def save
    if @user_id
      sql = <<-SQL
        UPDATE users
        SET first_name = ?, last_name = ?, is_instructor = ?
        WHERE user_id = ?
      SQL
      QuestionsDatabase.instance.execute(sql, @fname, @lname, @is_instructor, @user_id)
    else
      sql = <<-SQL
        INSERT INTO users
        ('first_name', 'last_name', 'is_instructor')
        VALUES (?, ?, ?)
      SQL
      QuestionsDatabase.instance.execute(sql, @fname, @lname, @is_instructor)
      @user_id = QuestionsDatabase.instance.last_insert_row_id
    end
  end


end

class Question
  def self.find(question_id)
    question = (QuestionsDatabase.instance.execute ("SELECT  * FROM questions JOIN users ON author=user_id WHERE question_id = #{question_id}"))[0]
    self.build_question(question)
  end

  def self.build_question(question)
    Question.new(question['body'], question['title'], question['question_id'], question['first_name'] + ' ' + question['last_name'])
  end

  def initialize(body, title, question_id, author)
    @body = body
    @title = title
    @question_id = question_id
    @author = author
  end

  def num_likes
    Like.question_count(@question_id)
  end

  def self.most_liked
    Like.most_liked
  end

  def followers
    sql = <<-SQL
      SELECT follower FROM question_followers
      WHERE question = ?
    SQL
    user_ids = QuestionsDatabase.instance.execute(sql, @question_id).map {|hash| hash['follower'] }
    users = []
    user_ids.each do |id|
      users << User.find(id)
    end
    users
  end

  def self.most_followed
    sql = <<-SQL
      SELECT question, count(follower) FROM question_followers
      GROUP BY question
      ORDER BY count(follower) desc
      LIMIT 1
    SQL
    data = (QuestionsDatabase.instance.execute(sql))[0]
    Question.find(data["question"])
  end

end

class Reply

end

class Actions

end

class Like
  def self.create(user_id, question_id)
    sql = <<-SQL
      INSERT INTO question_likes ('question_id', 'user_id') VALUES (#{question_id}, #{user_id})
    SQL
    QuestionsDatabase.instance.execute(sql)
  end

  def self.delete(user_id, question_id)
    QuestionsDatabase.instance.execute("DELETE FROM question_likes WHERE question_id = #{question_id} AND user_id = #{user_id}")
  end

  def self.question_count(question_id)
    sql = <<-QUERY
    SELECT COUNT(user_id) FROM question_likes WHERE question_id = (?)
    QUERY
    QuestionsDatabase.instance.execute(sql, question_id)
  end

  def self.most_liked
    sql = <<-QUERY
    SELECT count(q.question_id) number FROM question_likes ql
    JOIN questions q ON q.question_id = ql.question_id
    GROUP BY q.question_id
    ORDER BY count(q.question_id) desc
    LIMIT 1

    QUERY
    qid = QuestionsDatabase.instance.execute(sql)[0]['number']
    Question.find(qid)
  end
end