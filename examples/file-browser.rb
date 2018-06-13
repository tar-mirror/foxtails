#!/usr/bin/env ruby

require 'foxtails'
require 'foxtails/FTFileBrowser'

include Fox
include FoxTails

class FileBrowserMainWindow < FXMainWindow
  observable :directory
  signal :files_chosen
  
  def initialize(*args)
    super
    
    self.directory = Dir.pwd
    
    browser = nil # so that closures see this variable
    
    FXStatusBar.new(self,
       LAYOUT_SIDE_BOTTOM|LAYOUT_FILL_X|STATUSBAR_WITH_DRAGCORNER)      
    
    mb = FXMenuBar.new(self, LAYOUT_SIDE_TOP|LAYOUT_FILL_X)
    
    file_menu = FXMenuPane.new(self)
    FXMenuTitle.new(mb, "&File", nil, file_menu)

    FXMenuCommand.new(file_menu, "&Quit\tCtl-Q\tQuit the application.").
      connect(SEL_COMMAND) { getApp().exit }
    
    dir_label = FXLabel.new(self, "")
    when_directory(CHANGES) {dir_label.text = directory}
    
    browser = FTFileBrowser.new(self, self, :directory,
                  LAYOUT_FILL_X|LAYOUT_FILL_Y|FRAME_RAISED)
    
    browser.when_files_chosen do |files|
      FXMessageBox.information(self, MBOX_OK, "File Browser",
       "Opening files:\n#{files.join("\n")}")
    end

  end
  
  def create
    super
    show
  end
end

class FileBrowserApp < FTApp
  def initialize
    super("FileBrowser", "TEST")
    FoxTails.get_standard_icons
    FileBrowserMainWindow.new(self, "FileBrowser")
  end
end


FileBrowserApp.new.run
