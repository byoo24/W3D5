require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    # ...
    return @columns if @columns

    cols = DBConnection.instance.execute2(<<-SQL)
      SELECT *
      FROM #{table_name}
    SQL

    @columns = cols.first.map(&:to_sym)
  end


  def self.finalize!
    self.columns.each do |column|

      # GETTER
      define_method("#{column}") do 
        attributes[column]
      end

      # SETTER
      define_method("#{column}=") do |value|
        attributes[column] = value
      end

    end
  end

  def self.table_name=(table_name)
    # ...
    @table_name = table_name
  end

  def self.table_name
    # ...
    @table_name ||= self.name.downcase + "s"
  end

  def self.all
    # ...
    rows = DBConnection.execute(<<-SQL)
      SELECT *
      FROM #{table_name}
    SQL
    
    parse_all(rows)
  end

  def self.parse_all(results)
    # ...
    arr = []
    results.map do |hash|
      arr << self.new(hash)
    end

    arr

  end

  def self.find(id)
    # ...
    objects = self.all

    target = DBConnection.execute(<<-SQL)
      SELECT *
      FROM #{table_name}
      WHERE id = #{id}
    SQL
    target = target.first

    return nil if target.nil?
    self.new(target)
  end

  def initialize(params = {})
    # ...
    columns = self.class.columns

    params.each do |key, value|
      raise "unknown attribute '#{key}'" unless columns.include?(key.to_sym)

      self.send("#{key}=", value)
    end

  end

  def attributes
    # ...
    return @attributes ||= {}
  end

  def attribute_values
    # ...
    @attributes.values
  end

  def insert
    # ...
    col_names = self.class.columns[1..-1].join(',')
    sudo = Array.new(self.class.columns.length, '?')[1..-1].join(',')
    # debugger
    DBConnection.execute(<<-SQL, attributes)
      INSERT INTO #{@table_name} (#{col_names})
      VALUES (#{sudo})
    SQL
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
