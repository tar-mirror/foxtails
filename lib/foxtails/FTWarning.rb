module FoxTails

  ### This may be obsolete. Use foxtails/dialogs.rb instead.
  module FTWarning
    #
    # FTWarning.warn(string)
    #
    # Issue a warning that will appear as soon as possible.
    # This is useful when the condition occurs in non-GUI code
    # that doesn't have a window for the warning to belong to.
    #
    def self.warn(str)
      app = FXApp.instance
      app.addChore do
        FXMessageBox.warning(app.getMainWindow(), ## ??
          MBOX_OK, "Warning!", str)
      end
    end
    ## warnings should have classes, and there should be a checkbox to hide
    ## all warnings of that class
  end
  
end
