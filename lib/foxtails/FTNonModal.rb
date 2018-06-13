require "fox#{FoxTails::FXVER}/responder"

module FoxTails
  # Module to include in FXDialogBox to provide an easy nonmodal (and modal)
  # version of execute based on blocks.

  module FTNonModal
    include Responder

    def initialize(*args)
      super if defined?(super)
      FXMAPFUNC(SEL_COMMAND, FXDialogBox::ID_CANCEL, :onCmdCancel)
      FXMAPFUNC(SEL_COMMAND, FXDialogBox::ID_ACCEPT, :onCmdAccept)
      ## need to handle APPLY
    end

    # Creates and shows the dialog, and registers the associated block to be
    # called when the dialog is closed. The block is passed a boolean argument
    # which is true if and only if the dialog was accepted.

    def execute_nonmodal(*args, &block)
      @__FTNonModal_block = block
      create
      show(*args)
      setFocus ## ?
    end
    
    def execute_modal(*args, &block)
      @__FTNonModal_block = block
      execute(*args)
    end

    def onCmdCancel(*args) # :nodoc:
      on_nonmodal_close(false)
    end

    def onCmdAccept(*args) # :nodoc:
      on_nonmodal_close(true)
    end

    # Called when dialog is closed, with _accepted_ equal to true if and only if
    # the user accepted the dialog.
    
    def on_nonmodal_close(accepted) ## what arg for APPLY?
      @__FTNonModal_block[accepted] if @__FTNonModal_block

      ##return 0 -- why isn't this enough to close window?
      ## oh well, let's immitate FXTopWindow:
      getApp().stopModal(self, accepted ? 1 : 0)
      hide()
      
      # This seems to be needed since we're not using the Fox implementation.
      w = prev
      while w and not w.shown
        w = w.prev
      end
      if w
        w.setFocus
        w.raiseWindow
      end

      return 1
    end
  end
end
