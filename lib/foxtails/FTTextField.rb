require 'foxtails/FTTargeted'

module FoxTails

  class FTTextField < Fox::FXTextField
    include FTStateTargeted
    
    # Overrides the class's display method, if assigned.
    attr_accessor :display_format
    
    # Update the target value during editing or only when done?
    # The default is update when editing done (when field loses focus).
    attr_accessor :dynamic
    
    # The proc value of this attr should return true if the argument is
    # legal input for the field. As a shortcut, a block associated with
    # the initialization of the field is stored here. Note that only user
    # input is validated, and not data that comes from the observed var.
    attr_accessor :validator
    
    def initialize(*args, &block)
      super
      @validator = block
    end
    
    def valid(&block)
      @validator = block
    end
    
    def target_arg_range; 2..3; end

    def connect_to_target
      connect(SEL_FOCUSOUT) do
        set_target_state(get_value()) unless @dynamic
      end

      connect(SEL_CHANGED) do
        set_target_state(get_value()) if @dynamic
      end

      when_target_state CHANGES do |value|
        setText(formatted_display(value))
      end
    end
    
    def set_target_state(value)
      if @validator and not @validator[value]
        setText(formatted_display(get_target_state))
      else
        super
      end
    end
    
    def get_value
      getText()
    end
    
    def display(value)
      value.to_s
    end
    
    def formatted_display(value) ## refactor
      @display_format ?
        @display_format % value :
        display(value)
    end
  end
  
  FTStringField = FTTextField
  
  class FTIntegerField < FTTextField
    def initialize(*args)
      args[4] = (args[4] || TEXTFIELD_NORMAL) | TEXTFIELD_INTEGER
      super
      self.justify = JUSTIFY_RIGHT
    end
    def get_value
      super.to_i
    end
    def display(value)
      if value
        "%i" % value
      else
        ""
      end
    end
  end

  class FTFloatField < FTTextField
    attr_accessor :format, :precision
    
    DEFAULT_FLOAT_PRECISION = 2
    
    def initialize(*args)
      args[4] = (args[4] || TEXTFIELD_NORMAL) | TEXTFIELD_REAL
      super
      self.justify = JUSTIFY_RIGHT
    end
    def get_value
      super.to_f
    end
    def display(value)
      if value
        if format
          format % value
        else
          "%.#{precision || DEFAULT_FLOAT_PRECISION}f" % value
        end
      else
        ""
      end
    end
  end
  
  ## FTIntegerArrayField, ...
end
