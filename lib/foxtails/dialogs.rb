module FoxTails

  def FoxTails.show_warning title = "Warning", message = "Warning!",
                            button_names = ["Ok"]
    show_message(nil, title, message, button_names)
  end

  # returns the name of the button that was pressed, or nil if ESC
  def FoxTails.show_message owner, title, message, button_names = ["Ok"]
    owner ||= FTApp.instance.mainWindow
    result = nil

    dlg = FXDialogBox.new(owner, title,
            DECOR_TITLE|DECOR_BORDER|DECOR_RESIZE,
            0, 0, 400, 200)
    
    frame = FXVerticalFrame.new(dlg, LAYOUT_SIDE_TOP|
             LAYOUT_FILL_X|LAYOUT_FILL_Y)

    text_frame = FXHorizontalFrame.new(frame, LAYOUT_SIDE_TOP|
             LAYOUT_FILL_X|LAYOUT_FILL_Y|FRAME_SUNKEN)
    text_frame.padLeft = text_frame.padRight =
    text_frame.padTop = text_frame.padBottom = 0

    btn_frame = FXHorizontalFrame.new(frame, LAYOUT_SIDE_TOP|FRAME_NONE|
      PACK_UNIFORM_WIDTH|LAYOUT_CENTER_X)

    text = FXText.new(text_frame, nil, 0, TEXT_WORDWRAP|
             LAYOUT_FILL_X|LAYOUT_FILL_Y)
    text.editable = false
    text.text = message
    
    ## it might be nice to apply some simple markup to this text

    buttons = button_names.map do |button_name|
      button = FXButton.new(btn_frame, button_name)
      button.buttonStyle = BUTTON_DEFAULT|FRAME_RAISED|FRAME_THICK
      button.connect(SEL_COMMAND) do
        result = button_name
        dlg.handle(dlg, MKUINT(FXDialogBox::ID_ACCEPT, SEL_COMMAND), nil)
      end
      button
    end
    
    buttons[0].buttonStyle |= BUTTON_INITIAL
    buttons[0].setFocus
    
    dlg.execute(PLACEMENT_OWNER)
    
    result && result.gsub(/&/, "")
  end

  def FoxTails.show_exception message = "An exception occurred:",
                              pat = Exception
    yield
  rescue pat => e
    app = FTApp.instance || FTApp.new
    win = app.mainWindow || FXMainWindow.new(app, "")
    app.create
    FXMessageBox.error(win, MBOX_OK, e.class.name,
      "#{message}:\n\n" +
      e.message + "\n\n" +
      e.backtrace.join("\n"))
    ## would be nice to have enabled text so it can be copied out...
    ## so use show_message
    exit!
  end

end
