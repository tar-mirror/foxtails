require 'foxtails/FTTargeted'

module FoxTails

  # the list argument must be Enumerable
  class FTOptionMenu < Fox::FXOptionMenu
    include FTListStateTargeted
    
    def target_replacements(args); popup(args); end
    def target_arg_range; 1..3; end
    
    alias :list :get_target_list
    
    def popup(args = nil)
      @popup ||= FXPopup.new(args[0])
    end
    
    def option_list
      unless @option_list
        @option_list = list.map do |item|
          opt = FXOption.new(popup, display(item))
          opt.connect(SEL_COMMAND) do
            set_target_state(item)
          end
          opt
        end
      end
      @option_list
    end
    
    def connect_to_target
      option_list

      when_target_state CHANGES do |item|
        self.currentNo = index(item) || -1
      end
      
      when_target_list CHANGES do |new_list, old_list|
        if old_list
          raise NotImplementedError,
            "FTOptionMenu target list is not currently allowed to change." ##
        end
      end
    end
    
    def index(item)
      list && list.to_a.index(item)
    end
    
    def display(item)
      item.to_s
    end
    
    def create
      option_list # make sure the FXOptions will get created
      super
    end
  end
end
