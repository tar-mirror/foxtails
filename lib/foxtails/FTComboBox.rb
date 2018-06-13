require 'foxtails/FTTargeted'

module FoxTails

  ## this needs some work in the non-STATIC case

  # the list argument must be Enumerable
  class FTComboBox < Fox::FXComboBox
    include FTListStateTargeted

    def target_arg_range; 2..4; end
    
    alias :list :get_target_list
    
    def index(item)
      list && list.to_a.index(item)
    end
    
    def display(item)
      item.to_s
    end
    
    def recalc_list
      ## it would be best to just always do this on SEL_LEFTBUTTONPRESS,
      ## but that is mapped to a non-virtual function, and onListClicked
      ## is not available (so we can FXMAPFUNC to our own version which
      ## calls it), and the popup button doesn't go thru this anyway.
      clearItems
      list.each{|item| appendItem(display(item))} if list
        
      item = index(get_target_state)
begin
      setCurrentItem(item || 0)  ## disable if not on list?
rescue IndexError
 p item
end
      recalc_num_visible
    end
    
    def recalc_num_visible
      setNumVisible([numItems, numVisible].max)
    end
    
    def connect_to_target
      connect(SEL_COMMAND) do
        set_target_state(list.to_a[getCurrentItem])
      end

      when_target_state CHANGES do recalc_list end
      when_target_list  CHANGES do recalc_list end
        ## won't detect changes within the list, need to call writer explicitly
    end
  end
end
