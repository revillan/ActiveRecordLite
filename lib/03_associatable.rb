require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    # ...
    class_name.constantize
  end

  def table_name
    # ...
    # puts self.class
    class_name.downcase.concat("s")
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    # ...
    @foreign_key = options[:foreign_key].nil? ? "#{name}_id".to_sym : options[:foreign_key]
    @primary_key = options[:primary_key].nil? ? "id".to_sym : options[:primary_key]
    @class_name = options[:class_name].nil? ? name.to_s.singularize.capitalize : options[:class_name]

  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    # ...
    @foreign_key = options[:foreign_key].nil? ? "#{self_class_name}_id".downcase.to_sym : options[:foreign_key]
    @primary_key = options[:primary_key].nil? ? "id".to_sym : options[:primary_key]
    @class_name = options[:class_name].nil? ? name.to_s.singularize.capitalize : options[:class_name]
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    # p options
    # p options.class_name.constantize
    # p options.model_class
    # puts options.send(foreign_key)
    define_method name do
      foreign = options.send(:foreign_key).to_s
      p foreign
      classs = options.model_class
      House.where(id: foreign).first
    end
    # ...
  end

  def has_many(name, options = {})
    # ...
    options = HasManyOptions.new(name, self.class, options)
    # p options
    # p options.class_name.constantize
    # p options.model_class
    # puts options.send(foreign_key)
    define_method name do
      foreign = options.send(:foreign_key)
      p foreign

      classs = options.model_class
      House.where(primary_key: foreign).first
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  extend Associatable
  # Mixin Associatable here...
end
