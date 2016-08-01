require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject

  def self.columns
    @columns ||=  DBConnection.execute2(<<-SQL)
    SELECT
      *
    FROM
      #{table_name}
    SQL

    @columns.first.map! do |column|
      column.to_sym
    end
    # ...
  end

  def self.finalize!
    columns.each do |column|
      define_method "#{column}" do  # getter
        attributes[column]
      end

      define_method "#{column}=" do |val|       #setter
        attributes[column] = val
      end
    end
  end

  def self.table_name=(table_name)
    # ...
    @table_name = table_name
  end

  def self.table_name
    # ...
    table_name ||= self.to_s.downcase.concat("s")
  end

  def self.all
    # ...
    var_hash = DBConnection.execute(<<-SQL)
    SELECT
      *
    FROM
      #{self.table_name}
    SQL
    parse_all(var_hash)
  end

  def self.parse_all(results)
    # ...
    out = []
    results.each do |result|
      out << self.new(result)
    end
    out
  end

  def self.find(id)
    # ...
    result = DBConnection.execute(<<-SQL)
    SELECT
      *
    FROM
      #{table_name}
    WHERE
      id = #{id}
    SQL
    return nil if result.length == 0
    self.new(result[0])
  end

  def initialize(params = {})
    # ...

    params.each do |attr_name, value|
      unless self.class.columns.include?(attr_name.to_sym)
        raise "unknown attribute '#{attr_name}'"
      end
      self.send("#{attr_name}=", value)

    end
  end

  def attributes
    # ...
    @attributes ||= {}
  end

  def attribute_values
    # ...
    self.attributes.values
    # SQLObject.send(columns).map do |instance|
    #   puts instance
    # end
  end

  def insert
    # ...
    a = self.class.columns.map {|a| a.to_s}
    a.delete("id")
    col_names = a.join(", ")
    question_marks = (["?"] * (self.class.columns.length - 1)).join(", ")
    DBConnection.execute(<<-SQL, attribute_values)
    INSERT INTO
      #{self.class.table_name} ( #{col_names} )
    VALUES
      ( #{question_marks} )
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    # ...
    a = self.class.columns.dup
    a.map!{|b| b.to_s}.delete('id')
    a = a.map {|attr_name| "#{attr_name} = ?"}.join(", ")
    DBConnection.execute(<<-SQL, attribute_values.rotate)
    UPDATE
      #{self.class.table_name}
    SET
      #{a}
    WHERE
      id = ?
    SQL
  end

  def save
    # ...
    if id.nil?
      insert
    else
      update
    end
  end
end
