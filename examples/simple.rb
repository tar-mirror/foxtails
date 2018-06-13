#!/usr/bin/env ruby

require 'foxtails'

include Fox
include FoxTails

class SimpleMainWindow < FXMainWindow
  observable :items, :selected, :directory, :check, :height_range
  
  def initialize(*args)
    super
    
    self.items = 0..20  # Can be any Enumerable, but the slider, dial, and
                        # scroll are disabled unless it is a range
    self.selected = 2
    self.directory = Dir.pwd
    
    browser = nil # so that closures see this variable
    
    FXStatusBar.new(self,
       LAYOUT_SIDE_BOTTOM|LAYOUT_FILL_X|STATUSBAR_WITH_DRAGCORNER)      
    
    mb = FXMenuBar.new(self, LAYOUT_SIDE_TOP|LAYOUT_FILL_X)
    
    file_menu = FXMenuPane.new(self)
    FXMenuTitle.new(mb, "&File", nil, file_menu)

    FXMenuCommand.new(file_menu, "&Quit\tCtl-Q\tQuit the application.").
      connect(SEL_COMMAND) { getApp().exit }
    
    view_menu = FXMenuPane.new(self)
    FXMenuTitle.new(mb, "&View", nil, view_menu)
    FTCheckMenuCommand.new(view_menu,
      "File &browser\tCtl-B\tDisplay file browser.", nil,
      proc { browser }, :shown_state)
        # use proc because browser hasn't been assigned the FTFileBrowser yet
        # The check is updated when browser.shown_state is assigned
 
    text_field = nil
    FTEnabledMenuCommand.new(view_menu, "Fill text field (if editable)", nil,
                             proc {text_field}, :editable).
      connect(SEL_COMMAND) {text_field.text = "Some text..."}
    
    group1 = FXGroupBox.new(self, "Synchronized numeric controls",
      GROUPBOX_TITLE_LEFT|FRAME_RIDGE|LAYOUT_FILL_X)

    FTComboBox.new(group1, 20, self, :items, :selected,
                   COMBOBOX_STATIC|FRAME_THICK)
    
    f01 = FXHorizontalFrame.new(group1, LAYOUT_FILL_X)
    spinner = FTSpinner.new(f01, 10, self, :items, :selected, FRAME_SUNKEN)
    slider = FTSlider.new(f01, self, :items, :selected,
             SLIDER_HORIZONTAL|SLIDER_INSIDE_BAR|SLIDER_TICKS_TOP|LAYOUT_FILL_X)

    f02 = FXHorizontalFrame.new(group1, LAYOUT_FILL_X)
    dial = FTDial.new(f02, self, :items, :selected, 
                      DIAL_CYCLIC|DIAL_HAS_NOTCH|DIAL_HORIZONTAL|LAYOUT_FILL_X)

    f03 = FXHorizontalFrame.new(group1, LAYOUT_FILL_X)
    scroll = FTScrollBar.new(f03, self, :items, :selected, 
                      LAYOUT_FILL_X|SCROLLBAR_HORIZONTAL)
    
    int_field = FTIntegerField.new(f03, 10, self, :selected, FRAME_SUNKEN)
    
    [spinner, slider, dial, scroll].each {|ctl| ctl.dynamic = true}
    # let int_field.dynamic = false -- don't apply changes until you focus out
    
    pbar = FTProgressBar.new(group1, self, :items, :selected,
      LAYOUT_FILL_X|FRAME_SUNKEN|FRAME_THICK|PROGRESSBAR_PERCENTAGE)

    # dynamic popup reacts to change in items variable, state of browser
    FTPopupButton.new(group1, "Popup", PENGUIN_ICON) do
      menu = FXMenuPane.new(self)
        items.each do |i|
          FTRadioMenuCommand.new(menu, "Item #{i}", nil, self, :selected, i)
        end
        FXMenuSeparator.new(menu)
        if browser.shown_state
          FXMenuCommand.new(menu, "Hide file browser").
            connect(SEL_COMMAND) {browser.shown_state = false}
        else
          FXMenuCommand.new(menu, "Show file browser").
            connect(SEL_COMMAND) {browser.shown_state = true}
        end
      menu
    end

# This doesn't work yet --     
#    FXHorizontalSeparator.new(self)
#    
#      self.height_range = 0..1000
#      s = FTSlider.new(self, self, :height_range, :height,
#             SLIDER_HORIZONTAL|SLIDER_INSIDE_BAR|LAYOUT_FILL_X)
#      s.dynamic = false
#      
#      self.height = 700
      
    FXHorizontalSeparator.new(self)
    
      f1 = FXHorizontalFrame.new(self, LAYOUT_FILL_X)

      text_field = nil
      FTCheckButton.new(f1, "Editable:", proc {text_field}, :editable)
      text_field = FTTextField.new(f1, 20)
      
      FTCheckButton.new(f1, "Checkme 1", self, :check)
      FTCheckButton.new(f1, "Checkme 2", self, :check)
      
      FXButton.new(f1, "Reset checks").connect(SEL_COMMAND) { |*args|
        self.check = nil
      }
    
    FXHorizontalSeparator.new(self)
    
      f2 = FXHorizontalFrame.new(self, LAYOUT_FILL_X)

      FTButton.new(f2, "Show file browser", nil,
                          proc {browser}, :shown_state)
                          # defer reference to browser, which isn't there yet

      FTCheckButton.new(f2, "Show file browser",
                          proc {browser}, :shown_state)

      FTToggleButton.new(f2, "Show", "Hide", nil, nil,
                          proc {browser}, :shown_state)
    
    FXHorizontalSeparator.new(self)
    
      f3 = FXHorizontalFrame.new(self, LAYOUT_FILL_X)

      FTRadioButton.new(f3, "Mini icons",
                        proc {browser}, :show_icons_state, :mini)
      FTRadioButton.new(f3, "Big icons",
                        proc {browser}, :show_icons_state, :big)
      FTRadioButton.new(f3, "Details",
                        proc {browser}, :show_icons_state, :details)

      FTCheckButton.new(f3, "Enabled", proc {browser}, :enabled)
    
    FXHorizontalSeparator.new(self)
    
    dir_label = FXLabel.new(self, directory)
    when_directory(CHANGES) {dir_label.text = directory}
    
    browser = FTFileBrowser.new(self, self, :directory)
    
    browser.when_shown_state CHANGES do
      ###resize(defaultWidth, defaultHeight)
      ### not quite right -- why? Need to give exact w/h, subtracting
      ### browser size if necessary?
    end
    
    browser.when_files_chosen do |files|
      p files
    end
    # Equivalently:
    #def browser.open_named_files(files)
    #  p files
    #end
    
#    dir_label.when_shown CHANGES do |shown|
#      if shown
#        puts "dir_label is now shown"
#      else
#        puts "dir_label is now hidden"
#      end
#    end
#    
#    dir_label.shown=false
#    dir_label.shown=true

  end
  
  def create
    super
    show
  end
end

class SimpleApp < FTApp
  def initialize
    super("Simple", "TEST")
    FoxTails.get_standard_icons
    SimpleMainWindow.new(self, "Simple")
  end
end


SimpleApp.new.run
