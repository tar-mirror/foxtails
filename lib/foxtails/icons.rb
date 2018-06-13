module FoxTails

  ## when const_missing becomes standard, use it to implement this stuff
  ## and rescue get_icon failure with "missing" icon

  # Searches for +name+ first in the list of +dirs+, then in +icon_path+.
  def self.get_icon name, *dirs
    FTApp.instance.get_icon(name, *dirs)
  end
  
  # These icons are the PNG icons from the Fox examples plus some
  # of the internal Fox icons, converted to PNG files.
  
  # Returns true if method was already called, false otherwise.
  def self.get_standard_icons
    old_have_standard_icons = @have_standard_icons
    unless @have_standard_icons
      get_file_icons
      get_edit_icons
      get_browse_icons
      get_view_icons
      get_tree_icons
      get_misc_icons
      @have_standard_icons = true
    end
    old_have_standard_icons
  end
  
  def self.get_file_icons 
    unless @have_file_icons
      const_set :FILE_NEW_ICON,       get_icon("filenew.png")
      const_set :FILE_OPEN_ICON,      get_icon("fileopen.png")
      const_set :FILE_SAVE_ICON,      get_icon("filesave.png")
      const_set :FILE_SAVE_AS_ICON,   get_icon("filesaveas.png")
      const_set :FILE_REFRESH_ICON,   get_icon("redo.png")
      const_set :FILE_CLOSE_ICON,     get_icon("kill.png")
      const_set :PRINT_ICON,          get_icon("printicon.png")
      const_set :FOLDER_ICON,         get_icon("folder.png") 
        # from /usr/share/icons/crystalsvg/22x22/actions/fileopen.png
      @have_file_icons = true
    end
  end
  
  def self.get_edit_icons
    unless @have_edit_icons
      const_set :CUT_ICON,            get_icon("cut.png")
      const_set :COPY_ICON,           get_icon("copy.png")
      const_set :PASTE_ICON,          get_icon("paste.png")
      const_set :CLEAR_ICON,          get_icon("kill.png")
      @have_edit_icons = true
    end
  end
  
  def self.get_browse_icons
    unless @have_browse_icons
      const_set :HOME_ICON,           get_icon("home.png")
      const_set :UPLEVEL_ICON,        get_icon("uplevel.png")
      const_set :NEW_DIR_ICON,        get_icon("newdir.png")
      const_set :NEW_FOLDER_ICON,     get_icon("newfolder.png")
      const_set :LINK_ICON,           get_icon("link.png")
      const_set :MOVE_ICON,           get_icon("movefile.png")
      const_set :DELETE_ICON,         get_icon("deletefile.png")
      const_set :MARK_ICON,           get_icon("mark.png")
      const_set :CLEAR_MARKS_ICON,    get_icon("clear.png")
      @have_browse_icons = true
    end
  end

  def self.get_view_icons
    unless @have_view_icons
      const_set :PERSPECTIVE_ICON,    get_icon("perspective.png")
      const_set :PARALLEL_ICON,       get_icon("parallel.png")
      const_set :LIGHT_ICON,          get_icon("light.png")
      const_set :NO_LIGHT_ICON,       get_icon("nolight.png")
      const_set :SMOOTHLIGHT_ICON,    get_icon("smoothlight.png")
      const_set :FRONTVIEW_ICON,      get_icon("frontview.png")
      const_set :BACKVIEW_ICON,       get_icon("backview.png")
      const_set :LEFTVIEW_ICON,       get_icon("leftview.png")
      const_set :RIGHTVIEW_ICON,      get_icon("rightview.png")
      const_set :TOPVIEW_ICON,        get_icon("topview.png")
      const_set :BOTTOMVIEW_ICON,     get_icon("bottomview.png")
      const_set :ZOOM_ICON,           get_icon("zoom.png")
      const_set :CAMERA_ICON,         get_icon("camera.png")
      @have_view_icons = true
    end
  end
  
  def self.get_tree_icons
    unless @have_tree_icons
      const_set :FOLDER_OPEN_ICON,    get_icon("minifolderopen.png")
      const_set :FOLDER_CLOSED_ICON,  get_icon("minifolder.png")
      const_set :DOC_ICON,            get_icon("minidoc.png")
      @have_tree_icons = true
    end
  end
  
  def self.get_misc_icons
    unless @have_misc_icons
      const_set :PALETTE_ICON,        get_icon("colorpal.png")
      const_set :MDI_ICON,            get_icon("winapp.png")
      const_set :PENGUIN_ICON,        get_icon("penguin.png")
      const_set :FOX_ICON,            get_icon("foxicon.png")
      const_set :BLUE_LINE_ICON,      get_icon("solid_line.png")
      const_set :HELP_ICON,           get_icon("help.png")
      const_set :PROP_ICON,           get_icon("prop.png")
      const_set :PREFS_ICON,          get_icon("prefs.png")
      const_set :PLOT_ICON,           get_icon("gnuplot.png")
      
      # from FXMessageBox
      ## not sure why gif2png loses transparency on these?
      const_set :ERROR_ICON,          get_icon("error.gif")
      const_set :WARNING_ICON,        get_icon("warning.gif")
      const_set :INFO_ICON,           get_icon("info.gif")
      const_set :QUESTION_ICON,       get_icon("question.gif")
      
      # from /usr/share/icons/crystalsvg/16x16/actions/ok.png:
      const_set :UP_ICON,             get_icon("up.png")
      const_set :DOWN_ICON,           get_icon("down.png")
      const_set :OK_ICON,             get_icon("ok.png")
      const_set :CANCEL_ICON,         get_icon("cancel.png")
      
      @have_misc_icons = true
    end
  end

end
