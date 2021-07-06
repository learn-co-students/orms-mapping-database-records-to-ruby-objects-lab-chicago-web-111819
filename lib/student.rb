class Student
  attr_accessor :id, :name, :grade

  def self.new_from_db(row)
    # create a new Student object given a row from the database
    student = self.new
    student.id = row[0]
    student.name = row[1]
    student.grade = row[2]
    student
  end

  def self.all
    # retrieve all the rows from the "Students" database
    # remember each row should be a new instance of the Student class
    sql = "SELECT * FROM students;"
    students = DB[:conn].execute(sql).collect do |s|
      self.new_from_db(s)
    end
  end

  def self.all_students_in_grade_9
    sql = "SELECT * FROM students WHERE grade = 9;"
    DB[:conn].execute(sql).map
  end

  def self.students_below_12th_grade
    sql = "SELECT * FROM students WHERE grade < 12;"
    DB[:conn].execute(sql).collect do |s|
      self.new_from_db(s)
    end
  end

  def self.first_X_students_in_grade_10(num_students)
    sql = <<-SQL
      SELECT * FROM students
      WHERE grade = 10
      ORDER BY name LIMIT ?;
    SQL
    DB[:conn].execute(sql, num_students).map do |s|
      self.new_from_db(s)
    end
  end

  # 'first' as in 'first inserted into db ("id" is key)'
  # 'SELECT' results ordered by 'id' (primary key?) by default.
  def self.first_student_in_grade_10
    sql = <<-SQL
      SELECT * FROM students
      WHERE grade = 10 LIMIT 1;
    SQL
    q = DB[:conn].execute(sql)[0]
    self.new_from_db(q)
  end

  def self.all_students_in_grade_X(grade)
    sql = <<-SQL
      SELECT * FROM students
      WHERE grade = ?;
    SQL
    DB[:conn].execute(sql, grade)
  end

  def self.find_by_name(name)
    # find the student in the database given a name
    # return a new instance of the Student class
    sql = <<-SQL
      SELECT id, name, grade FROM students
      WHERE name = ? LIMIT 1;
    SQL
    self.new_from_db(DB[:conn].execute(sql, name).collect.first)
  end
  
  def save
    sql = <<-SQL
      INSERT INTO students (name, grade) 
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.grade)
  end
  
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end
end
