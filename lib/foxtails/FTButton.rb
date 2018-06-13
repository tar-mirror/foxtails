require 'foxtails/FTTargeted'

module FoxTails

  # Button whose state (up, down) is linked to the state of an
  # observable variable (true, false).
  
  module FTBooleanTargeted ## needs a better name -- module uses setState
    include FTStateTargeted
    
    def connect_to_target
      connect(SEL_COMMAND) { set_target_state(!get_target_state) }
      
      when_target_state true  do setState(true_state)  end
      when_target_state false do setState(false_state) end
    end
  end
  
  class FTButton < Fox::FXButton
    include FTBooleanTargeted
    def target_arg_range; 3..4;       end
    def true_state;       STATE_DOWN; end
    def false_state;      STATE_UP;   end
  end

  class FTCheckButton < Fox::FXCheckButton
    include FTBooleanTargeted
    def target_arg_range; 2..3;  end
    def true_state;       TRUE;  end
    def false_state;      FALSE; end
    
    def setState(s); setCheck(s); end
    
    def connect_to_target
      super
      when_target_state nil   do setCheck(MAYBE) end
    end
    
  end
  
  class FTToggleButton < Fox::FXToggleButton
    include FTBooleanTargeted
    def target_arg_range; 5..6;  end
    def true_state;       TRUE;  end
    def false_state;      FALSE; end
  end
  
  class FTRadioButton < Fox::FXRadioButton
    include FTStateTargeted
    def target_arg_range; 2..4;  end
    
    def init_target(target, state, value)
      super target, state
      @value = value
    end
    
    def connect_to_target
      connect(SEL_COMMAND) { set_target_state(@value) }

      when_target_state EQUAL[@value]     do setCheck(TRUE)  end
      when_target_state NOT_EQUAL[@value] do setCheck(FALSE) end
    end
  end
  
  # This class doesn't connect SEL_COMMAND to anything--that's up to the user.
  class FTEnabledButton < Fox::FXButton
    include FTStateTargeted
    def target_arg_range; 3..4;       end
    
    def connect_to_target
      when_target_state true  do enable  end
      when_target_state false do disable end
    end
  end

  ## FTOption and FTOptionMenu?
  ## FTMenuButton?
  ## FTArrowButton?
  
  # Performs an action while keeping the button in engaged state.
  ## This should be better integrated into the other buttons
  class FTActionButton < Fox::FXButton
    def initialize(*args, &action)
      super(*args, &nil) # don't pass action

      if action
        connect(SEL_COMMAND) do
          begin
            self.state = STATE_ENGAGED
            action.call
          ensure
            self.state = STATE_UP
          end
        end
      end
    end
  end

end
