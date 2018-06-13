module FoxTails

  # Can be included in any widget to allow definition of data entry fields.
  module FTField
    TEXT_FIELD_CLASS = {
      "s" => FTTextField,
      "d" => FTIntegerField,
      "f" => FTFloatField
    }
    
    DEFAULT_FIELD_WIDTH = 10
    
    class SpecificationError < StandardError; end
    
    # Returned by FTField#field.
    class FieldSpec
      include Enumerable
      def initialize(fields)  # :nodoc:
        @fields = fields
      end
      
      # Given a var name, as in the FTField#field arguments,
      # set the validator for the field to be the given block.
      def valid(var, &bl)
        @fields.assoc(var)[1].valid(&bl)
      end
      
      def each # :yields: [var, widget]
        @fields.each do |field|
          yield field
        end
      end
    end

    # Usage:
    #
    #   field("blah blah %10s foo bar %8.3f baz %8d",
    #         :str_var, :flt_var, :int_var)
    #
    # where str_var, flt_var, and int_var are observable.
    # Returns a FieldSpec.
    #
    # The precision part of the %f specifier is optional, the
    # default is FTFloatField::DEFAULT_FLOAT_PRECISION.
    #
    # Normally used within an initialize method, or in a method that
    # creates text fields.
    #
    # If one arg is a FXWindow, it is assumed to be the parent
    # for the fields, otherwise, self is used. Fields are created
    # under a FXHorizontalFrame.
    #
    # The substring %% is replaced by a single % in the output.
    #
    # White space at the either end of a field is deleted.
    #
    # A field spec %v inserts a checkbox targeted at the corr. var.
    #
    # A field spec %r inserts a radio button. The corr. var must be of
    # the form [:var, value]. Selecting the button assigns value to :var.
    # 
    # Any :var can be replaced with [obj, :var], if obj supports #var and
    # #var= methods.
    #
    # The field specifier %| can be used to divide up the string into
    # more than one framed collection of fields. Each frame is added
    # individually under the parent. This is useful when the parent
    # is a FXMatrix, or when you want fields to split across lines.
    def field(*args)
      parent = self
      args.delete_if do |arg|
        if FXWindow === arg
          parent = arg; true
        else
          false
        end
      end
      str, *vars = *args
      
      next_var = proc do
        vars.shift || (raise SpecificationError, "field: too few vars")
      end
      
      frame_strs = str.split(/\s*%\|\s*/)
      nested_fields = frame_strs.map do |frame_str|
        hframe = FXHorizontalFrame.new(parent, LAYOUT_FILL_X)
        hframe.padBottom = hframe.padTop = 0
        hframe.padLeft = hframe.padRight = 0
#        hframe.layoutHints = LAYOUT_CENTER_Y
        
        parts = frame_str.split(/(%.*?[sdfvrm])/).reject {|s|s.empty?}
          # reject, e.g., "%f foo" or "  %f%f  "
          
        parts.map do |part|
          case part
          when /\A%(?:(\d+)(?:\.(\d+))?)?([sdf])\z/ # Numeric or String field
            width = Integer($1 || DEFAULT_FIELD_WIDTH)
            prec = $2
            type = $3
            var = next_var[]
            w = TEXT_FIELD_CLASS[type].new(hframe, width, *make_target(var))
            w.precision = Integer(prec) if prec
          
          when "%v" # Check button
            var = next_var[]
            w = FTCheckButton.new(hframe, nil, *make_target(var))

          when "%r" # Radio button
            var, val = next_var[]
            w = FTRadioButton.new(hframe, nil, *(make_target(var)+[val]))
              ## val not stored in result
          
          when "%m" # Pop-up option menu
            w = FTOptionMenu.new(hframe,*make_list_target(*next_var[]))
              ## list not stored in result
          
          ## %l ==.list box

          else # Static text
            var = nil
            text = part.strip.gsub(/%%/, '%') ## too late: misses "%%d" !
            w = FXLabel.new(hframe, text)
          end

          w.layoutHints = LAYOUT_CENTER_Y

          [var, w]
        end
      end

      FieldSpec.new(nested_fields.inject([]){|r,a|r+a})
    end
    
    def make_target(var)
      case var
      when Symbol
        [self, var]
      else
        var
      end
    end
    
    def make_list_target(*args)
      case args.size
      when 2
        [self, *args]
      when 3
        args
      else
        raise
      end
    end
    
    private :make_target, :make_list_target
  end
  
end
