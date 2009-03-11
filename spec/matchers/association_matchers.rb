# Taken from http://snippets.dzone.com/posts/show/4721

module AssociationMatchers

  class AssociationReflection

    def initialize(type, name)
      @messages = {
        :missing_association =>
          '%s is not associated with %s.',
        :wrong_type =>
          "%s %s %s./nExpected: %s",
        :wrong_options =>
          "Options are incorrect.\nExpected: %s Got: %s",
        :missing_column =>
          "Missing foreign key.\nExpected: %s"
      }
      @name = name
      @expected_type = type
      @expected_options = {}
    end

    def matches?(target)
      Class === target or
        raise ArgumentError, 'class expected'

      @target = target

      unless @assoc = target.reflect_on_association(@name)
        @failure = :missing_association
        return false
      end

      unless @assoc.macro.eql?(@expected_type)
        @failure = :wrong_type
        return false
      end

      if @expected_options.any? { |o| @assoc.options[o.first] != o.last }
        @failure = :wrong_options
        return false
      end

      @column ||= @assoc.primary_key_name || @assoc.klass.name.foreign_key

      @failure = case @assoc.macro.to_s
      when 'belongs_to'
        if @target.column_names.include?(@column.to_s) then nil
        else
          :missing_column
        end
      when /(?:has_many|has_one)/
        if    @assoc.options[:through] then nil
        elsif @assoc.klass.column_names.include?(@column.to_s) then nil
        else
          :missing_column
        end
      end

      return @failure.nil?
    end

    def failure_message
      case @failure
      when :missing_association
        @messages[@failure] % [@target.name, @name]
      when :wrong_type
        @messages[@failure] % [
          @target.name,
          @assoc.macro,
          @name,
          @expected_type
        ]
      when :wrong_options
        @messages[@failure] % [
          @expected_options.inspect,
          @assoc.options.inspect
        ]
      when :missing_column
        @messages[@failure] % @column
      end
    end
    def negative_failure_message
    end

    # ### Generic Options

    def of(class_name)
      class_name = class_name.name if Class === class_name
      @expected_options[:class_name] = class_name
      self
    end
    def for(foreign_key)
        @column = foreign_key
        self
      end
      def due_to(conditions)
        @expected_options[:conditions] = conditions
        self
      end
      def ordered_by(statement)
        @expected_options[:order] = statement
        self
      end
      def including(*models)
        @expected_options[:include] = (models.length == 1)? models.first: models
        self
      end

    end

    class BelongsToReflection < AssociationReflection

      def initialize(name)
        super :belongs_to, name
      end

      def counted(column)
        @expected_options[:counter_cache] = column
        self
      end
      def polymorphic(true_or_false = true)
        @expected_options[:polymorphic] = true_or_false
        self
      end

    end
    class HasOneReflection < AssociationReflection

      def initialize(name)
        super :has_one, name
      end

      def as(interface_name)
        @expected_options[:as] = interface_name
        self
      end
      def depending(dependency = true)
        @expected_options[:dependent] = dependency
        self
      end
      def extended_by(mod)
        @expected_options[:extend] = mod
        self
      end

    end
    class HasManyReflection < AssociationReflection

      def initialize(name)
        super :has_many, name
      end

      def as(interface_name)
        @expected_options[:as] = interface_name
        self
      end
      def depending(dependency = :destroy)
        @expected_options[:dependent] = dependency
        self
      end

    end
    class HasAndBelongsToManyReflection < AssociationReflection

      def initialize(name)
        super :has_and_belongs_to_many, name
      end

    end

    def belong_to(model)
      BelongsToReflection.new model
    end
    def have_one(model)
      HasOneReflection.new model
    end
    def have_many(models)
      HasManyReflection.new models
    end
    def have_and_belong_to_many(models)
      HasAndBelongsToManyReflection.new models
    end
    alias_method :habtm, :have_and_belong_to_many

  end
