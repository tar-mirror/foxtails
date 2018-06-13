module FoxTails

  # a dynamic popup button, which creates its window each time
  class FTPopupButton < Fox::FXButton

    def initialize(*args, &make_popup)
      @make_popup = make_popup
#      super(*args, &nil)
      super(*args) {} # ruby 1.8.0 bug
      connect(SEL_COMMAND) {do_popup}
    end
    
    def do_popup
      self.state = STATE_ENGAGED
      w = @make_popup.call
      w.create
      pop_x, pop_y = translateCoordinatesTo(getRoot, 0, height)
      w.popup(nil, pop_x, pop_y)
      w.grabKeyboard
      getApp().runModalWhileShown(w)
    ensure
      self.state = STATE_UP
    end

  end
  
## This doesn't work:
#  class FTPopupButton2 < Fox::FXMenuButton
#  
#    def initialize(*args, &make_popup)
#      @make_popup = make_popup
#      super(*args,&nil)
#      connect(SEL_COMMAND) {setMenu(make_popup.call)}
#    end
#  
#  end

end
