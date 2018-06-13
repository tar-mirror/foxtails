require 'foxtails/FTTargeted'

module FoxTails

  module FTLinearControl
    include FTListStateTargeted ## FTRangeStateTargeted?
    include Observable::Match

    # Update the target value during editing or only when done?
    # The default is update when editing done (when mouse up).
    attr_accessor :dynamic

    def connect_to_target
      connect(SEL_COMMAND) do
        set_target_state(value)
      end

      connect(SEL_CHANGED) do
        set_target_state(value) if @dynamic
      end
      
      when_target_state CHANGES do |v|
        if v
          self.value = v
          enable
        else
          disable
        end
      end
      
      connect_to_target_list
    end
    
    def connect_to_target_list
      when_target_list CHANGES do |r|
        case r
        when Range
          self.range = r
          self.setIncrement(r.respond_to?(:increment) ? r.increment : 1)
        else # assume generic Enumerable
          disable
          ## use values in r or indices of r as our data points?
          ## indices works always, but for lists of numbers, that's
          ## probably not what we want
        end
      end
    end
    
  end

  class FTSlider < Fox::FXSlider
    include FTLinearControl
    def target_arg_range; 1..3; end
  end

  class FTSpinner < Fox::FXSpinner
    include FTLinearControl
    def target_arg_range; 2..4; end
  end
  
  class FTDial < Fox::FXDial
    include FTLinearControl
    def target_arg_range; 1..3; end

    def connect_to_target_list
      when_target_list CHANGES do |r|
        case r
        when Numeric
          self.range = r
          diff = r + 1
        when Range
          self.range = r
          diff = r.last + 1 - r.first
        else # assume generic Enumerable
          disable
          ## use values in r or indices of r as our data points?
          ## indices works always, but for lists of numbers, that's
          ## probably not what we want
        end

        # Some reasonable defaults:
        self.setRevolutionIncrement(diff*2)
        self.setNotchSpacing(180) ## better?
        self.setNotchOffset(0)
      end
    end
  end
  
  # Note: SCROLLERS_TRACK is ignored. Use #dynamic= .
  class FTScrollBar < Fox::FXScrollBar
    include FTLinearControl
    
    alias :value :position
    alias :value= :position=
    
    def target_arg_range; 1..3; end

    def connect_to_target_list
      when_target_list CHANGES do |r|
        case r
        when Numeric
          self.range = r
        when Range
          self.range = r.last + 1 - r.first
        else # assume generic Enumerable
          disable
          ## use values in r or indices of r as our data points?
          ## indices works always, but for lists of numbers, that's
          ## probably not what we want
        end
      end
    end
    
  end
  FTScrollbar = FTScrollBar

  class FTProgressBar < Fox::FXProgressBar
    include FTLinearControl
    
    alias :value :progress
    alias :value= :progress=
    
    def target_arg_range; 1..3; end

    def connect_to_target_list
      when_target_list CHANGES do |r|
        case r
        when Numeric
          self.total = r
        when Range
          self.total = r.last - r.first
        else # assume generic Enumerable
          disable
          ## use values in r or indices of r as our data points?
          ## indices works always, but for lists of numbers, that's
          ## probably not what we want
        end
      end
    end
  end
    
end
