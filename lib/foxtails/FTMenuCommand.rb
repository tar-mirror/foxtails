require 'foxtails/utils'
require 'foxtails/FTTargeted'

module FoxTails
  if Fox.fxversion.to_f >= 1.2
  
    class FTCheckMenuCommand < Fox::FXMenuCheck
      include FTStateTargeted
      def target_arg_range; 2..3;  end

      def connect_to_target
        connect(SEL_COMMAND) { set_target_state(check) } # NB: not !check

        when_target_state CHANGES do |v|
          self.check = v
        end
      end
    end

    class FTRadioMenuCommand < Fox::FXMenuRadio
      include FTStateTargeted
      def target_arg_range; 2..4;  end

      def init_target(target, state, value)
        super target, state
        @value = value
      end

      def connect_to_target
        connect(SEL_COMMAND) { set_target_state(@value) }

        when_target_state CHANGES do |v|
          self.check = (@value === v)
        end
      end
    end

  else

    class FTCheckMenuCommand < Fox::FXMenuCommand
      include FTStateTargeted
      def target_arg_range; 3..4;  end

      def connect_to_target
        connect(SEL_COMMAND) { set_target_state(!isChecked) }

        when_target_state true  do check   end
        when_target_state false do uncheck end
      end
    end

    class FTRadioMenuCommand < Fox::FXMenuCommand
      include FTStateTargeted
      def target_arg_range; 3..5;  end

      def init_target(target, state, value)
        super target, state
        @value = value
      end

      def connect_to_target
        connect(SEL_COMMAND) { set_target_state(@value) }

        when_target_state @value            do checkRadio   end
        when_target_state NOT_MATCH[@value] do uncheckRadio end
      end
    end
    
  end
  
  class FTEnabledMenuCommand < Fox::FXMenuCommand
    include FTStateTargeted
    def target_arg_range; 3..5;  end
    
    def init_target(target, state, value = EXISTS)
      super target, state
      @value = value
    end
    
    def connect_to_target
      when_target_state @value            do enable  end
      when_target_state NOT_MATCH[@value] do disable end
    end
  end

end
